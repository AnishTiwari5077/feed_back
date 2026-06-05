// lib/features/export/bloc/export_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../services/csv_export_service.dart';
import 'export_event.dart';
import 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final CsvExportService _csvExportService;
  final LocalAuthentication _localAuth;

  ExportBloc({
    required CsvExportService csvExportService,
    LocalAuthentication? localAuth,
  })  : _csvExportService = csvExportService,
        _localAuth = localAuth ?? LocalAuthentication(),
        super(const ExportInitial()) {
    on<ExportCsvRequested>(_onExportCsvRequested);
  }

  Future<void> _onExportCsvRequested(
    ExportCsvRequested event,
    Emitter<ExportState> emit,
  ) async {
    // Step 1: Biometric / password authentication
    emit(const ExportAuthenticating());
    try {
      final bool canAuthenticate =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        // Device doesn't support auth — proceed anyway (graceful fallback)
        emit(const ExportLoading());
        final message = await _csvExportService.exportToCSV();
        emit(ExportSuccess(message));
        return;
      }

      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to export feedback data',
        options: const AuthenticationOptions(
          biometricOnly: false, // allows password/PIN fallback
          stickyAuth: true,
        ),
      );

      if (!authenticated) {
        emit(const ExportAuthFailed());
        return;
      }

      // Step 2: Generate and save CSV
      emit(const ExportLoading());
      final message = await _csvExportService.exportToCSV();
      emit(ExportSuccess(message));
    } catch (e) {
      emit(ExportFailure('Export failed: ${e.toString()}'));
    }
  }
}
