// lib/core/di/injection.dart

import 'package:get_it/get_it.dart';
import '../../core/database/database_service.dart';
import '../../features/export/services/csv_export_service.dart';

/// GetIt service locator instance — globally accessible.
final getIt = GetIt.instance;

/// Register all dependencies. Called once in main() before runApp().
void setupDI() {
  // Database service — singleton
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());

  // CSV export service — depends on DatabaseService
  getIt.registerLazySingleton<CsvExportService>(
    () => CsvExportService(getIt<DatabaseService>()),
  );
}
