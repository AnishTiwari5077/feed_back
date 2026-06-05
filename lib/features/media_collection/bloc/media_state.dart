// lib/features/media_collection/bloc/media_state.dart

import 'package:equatable/equatable.dart';

enum MediaStatus { initial, loading, success, failure, submitting, submitted }

class MediaFile {
  final String path;
  final bool isVideo;

  const MediaFile({required this.path, this.isVideo = false});
}

class MediaState extends Equatable {
  final List<MediaFile> files;
  final MediaStatus status;
  final String? errorMessage;

  const MediaState({
    this.files = const [],
    this.status = MediaStatus.initial,
    this.errorMessage,
  });

  MediaState copyWith({
    List<MediaFile>? files,
    MediaStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MediaState(
      files: files ?? this.files,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  List<String> get filePaths => files.map((f) => f.path).toList();

  @override
  List<Object?> get props => [files.map((f) => f.path).toList(), status, errorMessage];
}
