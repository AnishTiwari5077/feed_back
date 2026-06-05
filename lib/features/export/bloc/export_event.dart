// lib/features/export/bloc/export_event.dart

import 'package:equatable/equatable.dart';

abstract class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers biometric authentication + CSV export flow.
class ExportCsvRequested extends ExportEvent {
  const ExportCsvRequested();
}
