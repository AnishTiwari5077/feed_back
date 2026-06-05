// lib/features/export/services/csv_export_service.dart

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_service.dart';

class CsvExportService {
  final DatabaseService _db;

  CsvExportService(this._db);

  Future<String> exportToCSV() async {
    final feedbackList = await _db.getAllFeedback();

    if (feedbackList.isEmpty) {
      return 'No feedback data to export.';
    }

    final rows = <List<dynamic>>[
      [
        'Device Owner',
        'User Details',
        'Bug/Issue',
        'User Device',
        'Description and Media Links',
      ],
      // Data rows
      ...feedbackList.map((f) => [
            f.deviceOwner,
            '${f.name} | ${f.email} | ${f.contact}',
            f.bugIssue,
            f.userDevice ?? 'Unknown',
            '${f.description} | Media: ${f.mediaLinks ?? 'None'}',
          ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final savedPath = await _saveToDownloads(csv);
    return '${AppConstants.csvFileName} saved to: $savedPath';
  }

  Future<String> _saveToDownloads(String csvContent) async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        // Fallback: try regular storage permission
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          // Last resort: save to app's external files directory
          return await _saveToExternalFiles(csvContent);
        }
      }
    }

    try {
      // Android: write to /storage/emulated/0/Download/
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (await downloadsDir.exists()) {
        final file = File('${downloadsDir.path}/${AppConstants.csvFileName}');
        await file.writeAsString(csvContent);
        return file.path;
      }
    } catch (_) {
      // fall through to external files
    }

    return await _saveToExternalFiles(csvContent);
  }

  Future<String> _saveToExternalFiles(String csvContent) async {
    // Reliable fallback: app external storage (visible in Files app)
    final dir = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${AppConstants.csvFileName}');
    await file.writeAsString(csvContent);
    return file.path;
  }
}
