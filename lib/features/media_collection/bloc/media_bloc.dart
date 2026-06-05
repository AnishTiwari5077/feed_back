// lib/features/media_collection/bloc/media_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'media_event.dart';
import 'media_state.dart';

class MediaBloc extends Bloc<MediaEvent, MediaState> {
  final ImagePicker _imagePicker;

  MediaBloc({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker(),
        super(const MediaState()) {
    on<MediaPickFromCamera>(_onPickFromCamera);
    on<MediaPickFromGallery>(_onPickFromGallery);
    on<MediaPickVideoFromCamera>(_onPickVideoFromCamera);
    on<MediaPickVideoFromGallery>(_onPickVideoFromGallery);
    on<MediaRemoved>(_onMediaRemoved);
    on<MediaSubmitted>(_onSubmitted);
    on<MediaReset>(_onReset);
  }

  Future<void> _onPickFromCamera(
    MediaPickFromCamera event,
    Emitter<MediaState> emit,
  ) async {
    emit(state.copyWith(status: MediaStatus.loading));
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.camera);
      if (image == null) {
        emit(state.copyWith(status: MediaStatus.initial));
        return;
      }
      final updated = [
        ...state.files,
        MediaFile(path: image.path, isVideo: false),
      ];
      emit(state.copyWith(files: updated, status: MediaStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: MediaStatus.failure,
        errorMessage: 'Camera error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onPickFromGallery(
    MediaPickFromGallery event,
    Emitter<MediaState> emit,
  ) async {
    emit(state.copyWith(status: MediaStatus.loading));
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isEmpty) {
        emit(state.copyWith(status: MediaStatus.initial));
        return;
      }
      final newFiles = images.map((x) => MediaFile(path: x.path)).toList();
      final updated = [...state.files, ...newFiles];
      emit(state.copyWith(files: updated, status: MediaStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: MediaStatus.failure,
        errorMessage: 'Gallery error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onPickVideoFromCamera(
    MediaPickVideoFromCamera event,
    Emitter<MediaState> emit,
  ) async {
    emit(state.copyWith(status: MediaStatus.loading));
    try {
      final XFile? video =
          await _imagePicker.pickVideo(source: ImageSource.camera);
      if (video == null) {
        emit(state.copyWith(status: MediaStatus.initial));
        return;
      }
      final updated = [
        ...state.files,
        MediaFile(path: video.path, isVideo: true),
      ];
      emit(state.copyWith(files: updated, status: MediaStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: MediaStatus.failure,
        errorMessage: 'Camera error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onPickVideoFromGallery(
    MediaPickVideoFromGallery event,
    Emitter<MediaState> emit,
  ) async {
    emit(state.copyWith(status: MediaStatus.loading));
    try {
      final XFile? video =
          await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video == null) {
        emit(state.copyWith(status: MediaStatus.initial));
        return;
      }
      final updated = [
        ...state.files,
        MediaFile(path: video.path, isVideo: true),
      ];
      emit(state.copyWith(files: updated, status: MediaStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: MediaStatus.failure,
        errorMessage: 'Gallery error: ${e.toString()}',
      ));
    }
  }

  void _onMediaRemoved(MediaRemoved event, Emitter<MediaState> emit) {
    final updated =
        state.files.where((f) => f.path != event.filePath).toList();
    emit(state.copyWith(files: updated, status: MediaStatus.success));
  }

  void _onSubmitted(MediaSubmitted event, Emitter<MediaState> emit) {
    emit(state.copyWith(status: MediaStatus.submitted));
  }

  void _onReset(MediaReset event, Emitter<MediaState> emit) {
    emit(const MediaState());
  }
}
