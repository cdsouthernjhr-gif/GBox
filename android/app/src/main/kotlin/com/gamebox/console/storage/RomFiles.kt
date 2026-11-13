package com.gamebox.console.storage

import android.content.ContentResolver
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.provider.DocumentsContract
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.security.MessageDigest
import java.util.zip.CRC32

/**
 * File operations for the ROM manager. Works with both Storage Access
 * Framework document URIs (`content://…`) and plain paths (app-specific
 * directories). Never executes or extracts anything.
 */
class RomFiles(private val context: Context) {

    private val resolver: ContentResolver get() = context.contentResolver

    private fun isContent(uri: String) = uri.startsWith("content://")

    private fun open(uri: String): InputStream =
        if (isContent(uri)) {
            resolver.openInputStream(Uri.parse(uri)) ?: throw IllegalStateException("Cannot open $uri")
        } else {
            File(uri).inputStream()
        }

    /**
     * Breadth-first walk of a SAF tree. Only files whose lower-case extension
     * is in [extensions] are returned, each with its folder path relative to
     * the tree root. Hidden entries (starting with '.') are skipped.
     */
    fun scanTree(
        treeUriString: String,
        extensions: Set<String>,
        maxDepth: Int,
        maxFiles: Int,
        subPath: String? = null,
    ): Map<String, Any?> {
        val treeUri = Uri.parse(treeUriString)
        val treeRoot = DocumentsContract.getTreeDocumentId(treeUri)
        val prefix = segments(subPath)
        // Start below the tree root when a sub-folder is given; paths in the
        // result stay relative to the tree root.
        val rootId = if (prefix.isEmpty()) treeRoot else (findDir(treeUri, prefix)
            ?: return mapOf("files" to emptyList<Any>(), "folders" to 0, "truncated" to false))
        val files = ArrayList<Map<String, Any?>>()
        var folders = 0
        var truncated = false
        val queue = ArrayDeque<Pair<String, List<String>>>()
        queue.add(rootId to prefix)
        val projection = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
            DocumentsContract.Document.COLUMN_SIZE,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED,
        )
        while (queue.isNotEmpty()) {
            val (docId, dir) = queue.removeFirst()
            folders++
            val children = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, docId)
            resolver.query(children, projection, null, null, null)?.use { c ->
                while (c.moveToNext()) {
                    val id = c.getString(0) ?: continue
                    val name = c.getString(1) ?: continue
                    if (name.startsWith(".")) continue
                    val mime = c.getString(2)
                    if (mime == DocumentsContract.Document.MIME_TYPE_DIR) {
                        if (dir.size - prefix.size < maxDepth) queue.add(id to (dir + name))
                        continue
                    }
                    val ext = name.substringAfterLast('.', "").lowercase()
                    if (ext !in extensions) continue
                    if (files.size >= maxFiles) {
                        truncated = true
                        break
                    }
                    files.add(
                        mapOf(
                            "uri" to DocumentsContract.buildDocumentUriUsingTree(treeUri, id).toString(),
                            "name" to name,
                            "dir" to dir,
                            "size" to if (c.isNull(3)) null else c.getLong(3),
                            "lastModified" to if (c.isNull(4)) null else c.getLong(4),
                        ),
                    )
                }
            }
            if (truncated) break
        }
        return mapOf("files" to files, "folders" to folders, "truncated" to truncated)
    }

    private fun segments(path: String?): List<String> =
        path?.split('/')?.map { it.trim() }?.filter { it.isNotEmpty() && it != "." && it != ".." } ?: emptyList()

    /** Document id of the child [name] of [parentId], or null. */
    private fun findChild(treeUri: Uri, parentId: String, name: String): Pair<String, Boolean>? {
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentId)
        resolver.query(
            children,
            arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID, DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                DocumentsContract.Document.COLUMN_MIME_TYPE),
            null, null, null,
        )?.use { c ->
            while (c.moveToNext()) {
                if (c.getString(1) == name) {
                    return c.getString(0) to (c.getString(2) == DocumentsContract.Document.MIME_TYPE_DIR)
                }
            }
        }
        return null
    }

    private fun childNames(treeUri: Uri, parentId: String): List<String> {
        val names = ArrayList<String>()
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentId)
        resolver.query(children, arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)?.use { c ->
            while (c.moveToNext()) c.getString(0)?.let { names.add(it) }
        }
        return names
    }

    /** Existing folder at [path] below the tree root, or null. */
    private fun findDir(treeUri: Uri, path: List<String>): String? {
        var id = DocumentsContract.getTreeDocumentId(treeUri)
        for (name in path) {
            val child = findChild(treeUri, id, name) ?: return null
            if (!child.second) return null
            id = child.first
        }
        return id
    }

    /** Folder at [path] below the tree root, created where missing. */
    private fun makeDir(treeUri: Uri, path: List<String>): String {
        var id = DocumentsContract.getTreeDocumentId(treeUri)
        for (name in path) {
            val child = findChild(treeUri, id, name)
            id = if (child != null) {
                if (!child.second) throw IllegalStateException("$name exists and is not a folder")
                child.first
            } else {
                val parent = DocumentsContract.buildDocumentUriUsingTree(treeUri, id)
                val created = DocumentsContract.createDocument(resolver, parent, DocumentsContract.Document.MIME_TYPE_DIR, name)
                    ?: throw IllegalStateException("Cannot create folder $name")
                DocumentsContract.getDocumentId(created)
            }
        }
        return id
    }

    /** Creates every folder in [paths] (relative to the tree root). */
    fun ensureDirs(treeUriString: String, paths: List<String>): Map<String, Any?> {
        val treeUri = Uri.parse(treeUriString)
        var ok = 0
        val failed = ArrayList<String>()
        for (p in paths) {
            try {
                makeDir(treeUri, segments(p))
                ok++
            } catch (e: Exception) {
                failed.add("$p: ${e.message}")
            }
        }
        return mapOf("ok" to ok, "failed" to failed)
    }

    /**
     * Copies the local file [srcPath] into the folder [dirPath] of the tree
     * (created if needed) as [name]; an existing file is never overwritten,
     * a free name "name (2).ext" is used instead. Returns the document URI.
     */
    fun writeToTree(treeUriString: String, dirPath: String, name: String, srcPath: String): String {
        val treeUri = Uri.parse(treeUriString)
        val dirId = makeDir(treeUri, segments(dirPath))
        val existing = childNames(treeUri, dirId).map { it.lowercase() }.toSet()
        val dot = name.lastIndexOf('.')
        val stem = if (dot > 0) name.substring(0, dot) else name
        val ext = if (dot > 0) name.substring(dot) else ""
        var finalName = name
        var n = 2
        while (finalName.lowercase() in existing) finalName = "$stem ($n)$ext".also { n++ }
        val parent = DocumentsContract.buildDocumentUriUsingTree(treeUri, dirId)
        val doc = DocumentsContract.createDocument(resolver, parent, "application/octet-stream", finalName)
            ?: throw IllegalStateException("Cannot create $finalName")
        try {
            resolver.openOutputStream(doc, "w")?.use { out ->
                File(srcPath).inputStream().use { it.copyTo(out, 256 * 1024) }
            } ?: throw IllegalStateException("Cannot write $finalName")
        } catch (e: Exception) {
            try { DocumentsContract.deleteDocument(resolver, doc) } catch (_: Exception) {}
            throw e
        }
        return DocumentsContract.buildDocumentUriUsingTree(treeUri, DocumentsContract.getDocumentId(doc)).toString()
    }

    /** File names directly inside [dirPath] of the tree (empty if missing). */
    fun listNames(treeUriString: String, dirPath: String): List<String> {
        val treeUri = Uri.parse(treeUriString)
        val id = findDir(treeUri, segments(dirPath)) ?: return emptyList()
        return childNames(treeUri, id)
    }

    /** True when the tree is still granted and its root can be queried. */
    fun treeAccessible(treeUriString: String): Boolean = try {
        val treeUri = Uri.parse(treeUriString)
        val granted = resolver.persistedUriPermissions.any { it.uri == treeUri && it.isReadPermission }
        val root = DocumentsContract.buildDocumentUriUsingTree(treeUri, DocumentsContract.getTreeDocumentId(treeUri))
        granted && (resolver.query(root, arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID), null, null, null)
            ?.use { it.moveToFirst() } ?: false)
    } catch (_: Exception) {
        false
    }

    fun exists(uri: String): Boolean = try {
        if (isContent(uri)) {
            resolver.query(Uri.parse(uri), arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID), null, null, null)
                ?.use { it.moveToFirst() } ?: false
        } else {
            File(uri).isFile
        }
    } catch (_: Exception) {
        false
    }

    /** Streams the whole file once to compute SHA-1, CRC32 and size. */
    fun hash(uri: String): Map<String, Any?> {
        val sha1 = MessageDigest.getInstance("SHA-1")
        val crc = CRC32()
        var size = 0L
        open(uri).use { input ->
            val buf = ByteArray(256 * 1024)
            while (true) {
                val n = input.read(buf)
                if (n <= 0) break
                sha1.update(buf, 0, n)
                crc.update(buf, 0, n)
                size += n
            }
        }
        return mapOf(
            "sha1" to sha1.digest().joinToString("") { "%02x".format(it) },
            "crc32" to "%08x".format(crc.value),
            "size" to size,
        )
    }

    /** Reads up to [length] bytes (max 1 MiB) starting at [offset]. */
    fun readBytes(uri: String, offset: Long, length: Int): ByteArray {
        val len = length.coerceIn(0, 1024 * 1024)
        open(uri).use { input ->
            var skipped = 0L
            while (skipped < offset) {
                val s = input.skip(offset - skipped)
                if (s <= 0) break
                skipped += s
            }
            val out = ByteArray(len)
            var total = 0
            while (total < len) {
                val n = input.read(out, total, len - total)
                if (n <= 0) break
                total += n
            }
            return if (total == len) out else out.copyOf(total)
        }
    }

    /**
     * Decodes an image (downscaled to at most [maxDim] px on the long side, to
     * protect 2 GB devices) and stores it as JPEG at [destPath]. Images larger
     * than 25 MB or that fail to decode are rejected.
     */
    fun importImage(uri: String, destPath: String, maxDim: Int): String? {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        open(uri).use { BitmapFactory.decodeStream(it, null, bounds) }
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null
        var sample = 1
        while (bounds.outWidth / (sample * 2) >= maxDim || bounds.outHeight / (sample * 2) >= maxDim) sample *= 2
        val opts = BitmapFactory.Options().apply {
            inSampleSize = sample
            inPreferredConfig = Bitmap.Config.RGB_565
        }
        val decoded = open(uri).use { BitmapFactory.decodeStream(it, null, opts) } ?: return null
        val scale = maxDim.toFloat() / maxOf(decoded.width, decoded.height)
        val bmp = if (scale < 1f) {
            Bitmap.createScaledBitmap(decoded, (decoded.width * scale).toInt(), (decoded.height * scale).toInt(), true)
                .also { if (it != decoded) decoded.recycle() }
        } else {
            decoded
        }
        val dest = File(destPath)
        dest.parentFile?.mkdirs()
        FileOutputStream(dest).use { bmp.compress(Bitmap.CompressFormat.JPEG, 88, it) }
        bmp.recycle()
        return dest.absolutePath
    }

    /** Display name and size of a document (OpenableColumns) or path. */
    fun describe(uri: String): Map<String, Any?> {
        if (!isContent(uri)) {
            val f = File(uri)
            return mapOf("uri" to uri, "name" to f.name, "size" to if (f.isFile) f.length() else null)
        }
        var name: String? = null
        var size: Long? = null
        try {
            resolver.query(
                Uri.parse(uri),
                arrayOf(android.provider.OpenableColumns.DISPLAY_NAME, android.provider.OpenableColumns.SIZE),
                null, null, null,
            )?.use { c ->
                if (c.moveToFirst()) {
                    name = c.getString(0)
                    size = if (c.isNull(1)) null else c.getLong(1)
                }
            }
        } catch (_: Exception) {
        }
        return mapOf("uri" to uri, "name" to (name ?: Uri.parse(uri).lastPathSegment ?: uri), "size" to size)
    }

    /** Copies [uri] (content or path) to the local file [destPath]. */
    fun copyToLocal(uri: String, destPath: String): Long {
        val dest = File(destPath)
        dest.parentFile?.mkdirs()
        val tmp = File("$destPath.tmp")
        open(uri).use { input -> FileOutputStream(tmp).use { input.copyTo(it, 256 * 1024) } }
        if (dest.exists()) dest.delete()
        if (!tmp.renameTo(dest)) throw IllegalStateException("Cannot write $destPath")
        return dest.length()
    }

    /**
     * Overwrites the existing document/file [destUri] with [srcPath]. Needs
     * write access (granted when the save folder was registered).
     */
    fun copyFromLocal(srcPath: String, destUri: String): Long {
        val src = File(srcPath)
        if (isContent(destUri)) {
            resolver.openOutputStream(Uri.parse(destUri), "wt")?.use { out ->
                src.inputStream().use { it.copyTo(out, 256 * 1024) }
            } ?: throw IllegalStateException("Cannot open $destUri for writing")
        } else {
            src.inputStream().use { input -> FileOutputStream(File(destUri)).use { input.copyTo(it, 256 * 1024) } }
        }
        return src.length()
    }

    /** Deletes the original file. Called only after explicit user confirmation. */
    fun delete(uri: String): Boolean = try {
        if (isContent(uri)) {
            DocumentsContract.deleteDocument(resolver, Uri.parse(uri))
        } else {
            File(uri).delete()
        }
    } catch (_: Exception) {
        false
    }
}
