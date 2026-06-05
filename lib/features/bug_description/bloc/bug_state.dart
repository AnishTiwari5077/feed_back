// lib/features/bug_description/bloc/bug_state.dart

import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';

enum BugStatus { initial, valid, invalid, submitting, success, failure }

class BugState extends Equatable {
  final String title;
  final String description;
  final BugStatus status;
  final String? titleError;
  final String? descriptionError;

  const BugState({
    this.title = '',
    this.description = '',
    this.status = BugStatus.initial,
    this.titleError,
    this.descriptionError,
  });

  int get descriptionLength => description.length;
  int get descriptionMaxLength => AppConstants.descriptionMaxLength;

  bool get isValid =>
      titleError == null &&
      descriptionError == null &&
      title.isNotEmpty &&
      description.isNotEmpty;

  BugState copyWith({
    String? title,
    String? description,
    BugStatus? status,
    String? titleError,
    String? descriptionError,
    bool clearTitleError = false,
    bool clearDescriptionError = false,
  }) {
    return BugState(
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      titleError: clearTitleError ? null : (titleError ?? this.titleError),
      descriptionError: clearDescriptionError
          ? null
          : (descriptionError ?? this.descriptionError),
    );
  }

  @override
  List<Object?> get props =>
      [title, description, status, titleError, descriptionError];
}
