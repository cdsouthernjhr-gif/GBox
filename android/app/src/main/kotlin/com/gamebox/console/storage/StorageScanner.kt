package com.gamebox.console.storage

import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.os.storage.StorageManager
import java.io.File

/**
 * Enumerates storage volumes without assuming vendor-specific mount paths.
 *
 * Uses app-specific external directories (always accessible, no permission)
 * to find mounted volumes and StorageManager (API 24+) for descriptions and
 * unmounted/removed volumes. Raw paths are informational only: file access to
 * removable media goes through the Storage Access Framework.
 */
class StorageScanner(private val context: Context) {

    fun volumes(): List<Map<String, Any?>> {
        val out = ArrayList<Map<String, Any?>>()
        val seenIds = HashSet<String>()
        val sm = context.getSystemService(Context.STORAGE_SERVICE) as StorageManager

        val dirs = context.getExternalFilesDirs(null)
        dirs.forEachIndexed { index, dir ->
            if (dir == null) return@forEachIndexed // volume currently unavailable
            val root = dir.absolutePath.substringBefore("/Android/data/")
            val state = try { Environment.getExternalStorageState(dir) } catch (t: Throwable) { "unknown" }
            val removable = try { Environment.isExternalStorageRemovable(dir) } catch (t: Throwable) { index > 0 }
            val emulated = try { Environment.isExternalStorageEmulated(dir) } catch (t: Throwable) { index == 0 }

            var description: String? = null
            var uuid: String? = null
            var primary = index == 0
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                sm.getStorageVolume(dir)?.let { v ->
                    description = v.getDescription(context)
                    uuid = v.uuid
                    primary = v.isPrimary
                }
            }
            val id = when {
                primary -> "primary"
                uuid != null -> uuid!!
                else -> root
            }
            seenIds.add(id)
            out.add(
                volumeMap(
                    id = id,
                    description = description ?: if (primary) "Internal storage" else "External storage",
                    primary = primary,
                    removable = removable,
                    emulated = emulated,
                    state = state,
                    path = root,
                    statPath = dir.path,
                ),
            )
        }

        // Volumes known to the system but not currently mounted (API 24+).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            for (v in sm.storageVolumes) {
                val id = if (v.isPrimary) "primary" else v.uuid ?: continue
                if (id in seenIds) continue
                seenIds.add(id)
                val path = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) v.directory?.path else null
                out.add(
                    volumeMap(
                        id = id,
                        description = v.getDescription(context),
                        primary = v.isPrimary,
                        removable = v.isRemovable,
                        emulated = v.isEmulated,
                        state = v.state,
                        path = path,
                        statPath = null,
                    ),
                )
            }
        }

        if (out.none { it["isPrimary"] == true }) {
            val data = Environment.getDataDirectory()
            out.add(
                0,
                volumeMap("primary", "Internal storage", true, false, true, "mounted", data.path, data.path),
            )
        }
        return out
    }

    private fun volumeMap(
        id: String,
        description: String,
        primary: Boolean,
        removable: Boolean,
        emulated: Boolean,
        state: String,
        path: String?,
        statPath: String?,
    ): Map<String, Any?> {
        var total: Long? = null
        var avail: Long? = null
        if (statPath != null) {
            try {
                val st = StatFs(statPath)
                total = st.totalBytes
                avail = st.availableBytes
            } catch (_: Throwable) {
            }
        }
        val lower = description.lowercase()
        val kind = when {
            primary || !removable -> "internal"
            lower.contains("usb") -> "usb"
            lower.contains("sd") -> "sdCard"
            else -> "unknown"
        }
        return mapOf(
            "id" to id,
            "description" to description,
            "isPrimary" to primary,
            "isRemovable" to removable,
            "isEmulated" to emulated,
            "state" to state,
            "path" to path,
            "totalBytes" to total,
            "availableBytes" to avail,
            "kind" to kind,
        )
    }
}
