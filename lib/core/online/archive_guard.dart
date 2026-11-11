/// ZIP inspection and guarded extraction.
///
/// Archives are validated *before* anything is written:
/// * entry paths must be relative and stay inside the destination
///   (no absolute paths, drive letters, `..` or backslash tricks);
/// * symbolic links are refused;
/// * entry count, single-entry size, total size and compression ratio are
///   limited (archive-bomb protection).
/// During extraction the bytes actually written are counted again, so a
/// header that lies about sizes is caught too. Nothing extracted is executed.
library;

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

class ArchiveLimits {
  const ArchiveLimits({
    this.maxEntries = 2000,
    this.maxEntryBytes = 4 * 1024 * 1024 * 1024,
    this.maxTotalBytes = 8 * 1024 * 1024 * 1024,
    this.maxRatio = 200,
  });
  final int maxEntries;
  final int maxEntryBytes;
  final int maxTotalBytes;

  /// Max uncompressed/compressed ratio for entries larger than 1 MB.
  final int maxRatio;
}

class ArchiveInspection {
  const ArchiveInspection({required this.problems, required this.entries, required this.totalBytes});
  final List<String> problems;

  /// Safe relative paths of file entries.
  final List<String> entries;
  final int totalBytes;
  bool get ok => problems.isEmpty;
}

/// Normalised relative path for an archive entry, or null if unsafe.
String? safeEntryPath(String name) {
  if (name.isEmpty || name.contains('\u0000')) return null;
  final n = name.replaceAll('\\', '/');
  if (n.startsWith('/') || RegExp(r'^[A-Za-z]:').hasMatch(n)) return null;
  final parts = n.split('/').where((s) => s.isNotEmpty && s != '.').toList();
  if (parts.isEmpty || parts.any((s) => s == '..')) return null;
  return parts.join('/');
}

bool _isSymlink(ZipFileHeader h) => ((h.externalFileAttributes >> 16) & 0xF000) == 0xA000;

ArchiveInspection inspectZip(String path, {ArchiveLimits limits = const ArchiveLimits()}) {
  final problems = <String>[];
  final entries = <String>[];
  var total = 0;
  // A ZIP starts with a local file header (PK\x03\x04) or, if empty, the
  // end-of-central-directory record (PK\x05\x06).
  try {
    final head = File(path).openSync()..setPositionSync(0);
    final sig = head.readSync(4);
    head.closeSync();
    if (sig.length < 4 || sig[0] != 0x50 || sig[1] != 0x4B || !((sig[2] == 3 && sig[3] == 4) || (sig[2] == 5 && sig[3] == 6))) {
      return const ArchiveInspection(problems: ['Not a valid ZIP archive'], entries: [], totalBytes: 0);
    }
  } on FileSystemException catch (e) {
    return ArchiveInspection(problems: ['Cannot read archive: ${e.message}'], entries: const [], totalBytes: 0);
  }
  final input = InputFileStream(path);
  try {
    final dir = ZipDirectory();
    try {
      dir.read(input);
    } catch (e) {
      return ArchiveInspection(problems: ['Not a valid ZIP archive ($e)'], entries: const [], totalBytes: 0);
    }
    if (dir.fileHeaders.length > limits.maxEntries) {
      problems.add('Too many entries (${dir.fileHeaders.length} > ${limits.maxEntries})');
    }
    for (final h in dir.fileHeaders) {
      final isDir = h.filename.endsWith('/') || h.filename.endsWith('\\');
      final safe = safeEntryPath(h.filename);
      if (safe == null) {
        problems.add('Unsafe path in archive: "${h.filename}"');
        continue;
      }
      if (_isSymlink(h)) {
        problems.add('Symbolic link in archive: "${h.filename}"');
        continue;
      }
      if (isDir) continue;
      final size = h.uncompressedSize;
      if (size > limits.maxEntryBytes) problems.add('Entry too large: $safe');
      if (size > 1024 * 1024 && h.compressedSize > 0 && size / h.compressedSize > limits.maxRatio) {
        problems.add('Suspicious compression ratio (possible archive bomb): $safe');
      }
      total += size;
      entries.add(safe);
    }
    if (total > limits.maxTotalBytes) problems.add('Archive expands to more than the allowed size');
    if (entries.isEmpty && problems.isEmpty) problems.add('Archive contains no files');
  } finally {
    input.closeSync();
  }
  return ArchiveInspection(problems: problems, entries: entries, totalBytes: total);
}

class ExtractionResult {
  const ExtractionResult({required this.files, this.error});
  final List<String> files;
  final String? error;
  bool get ok => error == null;
}

/// Extracts a ZIP that passed [inspectZip] into [destDir].
Future<ExtractionResult> extractZip(String path, String destDir, {ArchiveLimits limits = const ArchiveLimits()}) async {
  final inspection = inspectZip(path, limits: limits);
  if (!inspection.ok) return ExtractionResult(files: const [], error: inspection.problems.join('\n'));
  final root = p.normalize(p.absolute(destDir));
  await Directory(root).create(recursive: true);
  final written = <String>[];
  var total = 0;
  final input = InputFileStream(path);
  try {
    final archive = ZipDecoder().decodeStream(input);
    for (final f in archive) {
      if (!f.isFile || f.isSymbolicLink) continue;
      final rel = safeEntryPath(f.name);
      if (rel == null) continue;
      final out = p.normalize(p.join(root, rel));
      if (!p.isWithin(root, out)) {
        return ExtractionResult(files: written, error: 'Unsafe path in archive: "${f.name}"');
      }
      await File(out).parent.create(recursive: true);
      final stream = OutputFileStream(out);
      try {
        f.writeContent(stream);
      } finally {
        stream.closeSync();
      }
      final len = await File(out).length();
      total += len;
      written.add(out);
      if (len > limits.maxEntryBytes || total > limits.maxTotalBytes) {
        for (final w in written) {
          try {
            await File(w).delete();
          } catch (_) {}
        }
        return const ExtractionResult(files: [], error: 'Archive expanded beyond the allowed size; extraction undone');
      }
    }
  } catch (e) {
    return ExtractionResult(files: written, error: 'Extraction failed: $e');
  } finally {
    input.closeSync();
  }
  return ExtractionResult(files: written);
}
