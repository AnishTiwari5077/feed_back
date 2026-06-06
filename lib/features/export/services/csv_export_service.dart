// lib/features/export/services/csv_export_service.dart

import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:media_store_plus/media_store_plus.dart';
import '../../../core/database/database_service.dart';

class CsvExportService {
  final DatabaseService _db;
  CsvExportService(this._db);

  Future<String> exportToCSV() async {
    final feedbackList = await _db.getAllFeedback();

    if (feedbackList.isEmpty) {
      return 'No feedback data to export.';
    }

    final buffer = StringBuffer();

    // ── Header row — exact 5 columns from assignment ──
    buffer.writeln(
      '"Device Owner","User Details","Bug/Issue",'
      '"User Device","Description and Media Links"',
    );

    // ── Data rows ──
    for (final f in feedbackList) {
      // Column 1 — Device Owner (Google account email)
      final deviceOwner = _sanitize(f.deviceOwner);

      // Column 2 — User Details (name + email + contact combined)
      final userDetails = _sanitize(
        'Name: ${f.name} | Email: ${f.email} | Contact: ${f.contact}',
      );

      // Column 3 — Bug/Issue title
      final bugIssue = _sanitize(f.bugIssue);

      // Column 4 — User Device (auto-detected model)
      final userDevice = _sanitize(f.userDevice ?? 'Unknown Device');

      // Column 5 — Description + readable media filenames
      final mediaReadable = _formatMediaLinks(f.mediaLinks);
      final descAndMedia = _sanitize(
        '${f.description}\nMedia: $mediaReadable'
        '\nSubmitted: ${_formatDate(f.createdAt)}',
      );

      buffer.writeln(
        '"$deviceOwner","$userDetails","$bugIssue",'
        '"$userDevice","$descAndMedia"',
      );
    }

    // ── Save to temp file ──
    final tempDir = await getTemporaryDirectory();
    final fileName = 'feedback_export_${_formatDateForFile()}.csv';
    final tempFile = File('${tempDir.path}/$fileName');

    // UTF-8 BOM — forces Excel to open with correct encoding
    // and recognize comma as separator
    await tempFile.writeAsBytes(
      [0xEF, 0xBB, 0xBF], // UTF-8 BOM
    );
    await tempFile.writeAsString(
      buffer.toString(),
      mode: FileMode.append,
      encoding: const Utf8Codec(),
    );

    // ── Save to Downloads via scoped storage ──
    await MediaStore().saveFile(
      tempFilePath: tempFile.path,
      dirType: DirType.download,
      dirName: DirName.download,
    );

    return 'Saved to Downloads/$fileName';
  }

  // ── Sanitize: escape quotes, prevent injection ──
  String _sanitize(String value) {
    // Replace internal double quotes with two double quotes (CSV standard)
    return value.replaceAll('"', '""').replaceAll('\r', '');
  }

  // ── Convert raw cache path → readable filename only ──
  String _formatMediaLinks(String? mediaLinks) {
    if (mediaLinks == null || mediaLinks.isEmpty) return 'No media attached';

    return mediaLinks
        .split(',')
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .map((path) => path.split('/').last) // extract filename only
        .join(', ');
  }

  // ── Format ISO date → readable ──
  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day}/${dt.month}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatDateForFile() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
