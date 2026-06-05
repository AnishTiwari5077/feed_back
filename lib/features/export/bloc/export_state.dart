// lib/features/export/bloc/export_state.dart

import 'package:equatable/equatable.dart';

abstract class ExportState extends Equatable {
  const ExportState();

  @override
  List<Object?> get props => [];
}

class ExportInitial extends ExportState {
  const ExportInitial();
}

class ExportAuthenticating extends ExportState {
  const ExportAuthenticating();
}

class ExportLoading extends ExportState {
  const ExportLoading();
}

class ExportSuccess extends ExportState {
  final String message;
  const ExportSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ExportAuthFailed extends ExportState {
  const ExportAuthFailed();
}

class ExportFailure extends ExportState {
  final String message;
  const ExportFailure(this.message);

  @override
  List<Object?> get props => [message];
}
