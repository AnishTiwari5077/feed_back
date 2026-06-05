// lib/features/feedback_cubit/feedback_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/feedback_model.dart';

/// FeedbackState holds the accumulated form data from all screens.
/// Data is committed to the database only on final Submit (Screen 4).
class FeedbackState {
  final String deviceOwner;
  final String name;
  final String email;
  final String contact;
  final String bugIssue;
  final String? userDevice;
  final String description;
  final List<String> mediaPaths; // local/scoped URI paths

  const FeedbackState({
    this.deviceOwner = '',
    this.name = '',
    this.email = '',
    this.contact = '',
    this.bugIssue = '',
    this.userDevice,
    this.description = '',
    this.mediaPaths = const [],
  });

  FeedbackState copyWith({
    String? deviceOwner,
    String? name,
    String? email,
    String? contact,
    String? bugIssue,
    String? userDevice,
    String? description,
    List<String>? mediaPaths,
  }) {
    return FeedbackState(
      deviceOwner: deviceOwner ?? this.deviceOwner,
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      bugIssue: bugIssue ?? this.bugIssue,
      userDevice: userDevice ?? this.userDevice,
      description: description ?? this.description,
      mediaPaths: mediaPaths ?? this.mediaPaths,
    );
  }

  /// Convert to a FeedbackModel ready for DB insertion.
  FeedbackModel toFeedbackModel() {
    return FeedbackModel(
      deviceOwner: deviceOwner,
      name: name,
      email: email,
      contact: contact,
      bugIssue: bugIssue,
      userDevice: userDevice,
      description: description,
      mediaLinks: mediaPaths.isNotEmpty ? mediaPaths.join(',') : null,
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}

/// Cubit that accumulates form fields across all 5 screens.
/// The BLoC-per-screen pattern handles validation; this cubit holds shared state.
class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit() : super(const FeedbackState());

  void setDeviceOwner(String email) =>
      emit(state.copyWith(deviceOwner: email));

  void setUserDetails({
    required String name,
    required String email,
    required String contact,
    String? userDevice,
  }) {
    emit(state.copyWith(
      name: name,
      email: email,
      contact: contact,
      userDevice: userDevice,
    ));
  }

  void setBugDetails({
    required String bugIssue,
    required String description,
  }) {
    emit(state.copyWith(bugIssue: bugIssue, description: description));
  }

  void setMediaPaths(List<String> paths) =>
      emit(state.copyWith(mediaPaths: paths));

  void addMediaPath(String path) =>
      emit(state.copyWith(mediaPaths: [...state.mediaPaths, path]));

  void removeMediaPath(String path) => emit(
        state.copyWith(
          mediaPaths: state.mediaPaths.where((p) => p != path).toList(),
        ),
      );

  /// Reset all form data for a new feedback entry (after Thank You screen).
  void reset() => emit(const FeedbackState());
}
