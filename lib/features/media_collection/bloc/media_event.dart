// lib/features/media_collection/bloc/media_event.dart

import 'package:equatable/equatable.dart';

abstract class MediaEvent extends Equatable {
  const MediaEvent();

  @override
  List<Object?> get props => [];
}

class MediaPickFromCamera extends MediaEvent {
  const MediaPickFromCamera();
}

class MediaPickFromGallery extends MediaEvent {
  const MediaPickFromGallery();
}

class MediaPickVideoFromCamera extends MediaEvent {
  const MediaPickVideoFromCamera();
}

class MediaPickVideoFromGallery extends MediaEvent {
  const MediaPickVideoFromGallery();
}

class MediaRemoved extends MediaEvent {
  final String filePath;
  const MediaRemoved(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class MediaSubmitted extends MediaEvent {
  const MediaSubmitted();
}

class MediaReset extends MediaEvent {
  const MediaReset();
}
