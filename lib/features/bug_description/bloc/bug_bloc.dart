// lib/features/bug_description/bloc/bug_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import 'bug_event.dart';
import 'bug_state.dart';

class BugBloc extends Bloc<BugEvent, BugState> {
  BugBloc() : super(const BugState()) {
    on<BugTitleChanged>(_onTitleChanged);
    on<BugDescriptionChanged>(_onDescriptionChanged);
    on<BugSubmitted>(_onSubmitted);
    on<BugReset>(_onReset);
  }

  void _onTitleChanged(BugTitleChanged event, Emitter<BugState> emit) {
    final error = _validateTitle(event.title);
    emit(state.copyWith(
      title: event.title,
      titleError: error,
      clearTitleError: error == null,
    ));
  }

  void _onDescriptionChanged(
    BugDescriptionChanged event,
    Emitter<BugState> emit,
  ) {
    final error = _validateDescription(event.description);
    emit(state.copyWith(
      description: event.description,
      descriptionError: error,
      clearDescriptionError: error == null,
    ));
  }

  void _onSubmitted(BugSubmitted event, Emitter<BugState> emit) {
    final titleError = _validateTitle(state.title);
    final descriptionError = _validateDescription(state.description);

    if (titleError != null || descriptionError != null) {
      emit(state.copyWith(
        titleError: titleError,
        descriptionError: descriptionError,
        status: BugStatus.invalid,
      ));
      return;
    }
    emit(state.copyWith(status: BugStatus.success));
  }

  void _onReset(BugReset event, Emitter<BugState> emit) {
    emit(const BugState());
  }

  String? _validateTitle(String title) {
    if (title.trim().isEmpty) return 'Bug/issue title is required';
    if (title.trim().length < 5) return 'Title must be at least 5 characters';
    if (title.length > AppConstants.bugTitleMaxLength) {
      return 'Title must be less than ${AppConstants.bugTitleMaxLength} characters';
    }
    return null;
  }

  String? _validateDescription(String desc) {
    if (desc.trim().isEmpty) return 'Description is required';
    if (desc.trim().length < 10) {
      return 'Please describe the issue in more detail';
    }
    if (desc.length > AppConstants.descriptionMaxLength) {
      return 'Description exceeds maximum length of ${AppConstants.descriptionMaxLength} characters';
    }
    return null;
  }
}
