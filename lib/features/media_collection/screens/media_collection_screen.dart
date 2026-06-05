// lib/features/media_collection/screens/media_collection_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_service.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/feedback_cubit/feedback_cubit.dart';
import '../bloc/media_bloc.dart';
import '../bloc/media_event.dart';
import '../bloc/media_state.dart';

/// Screen 4 — Media Collection
/// Attach screenshots, images, or videos via image_picker.
/// Preview thumbnails with individual remove buttons.
/// On Submit: saves media URIs to DB + navigates to Thank You.
class MediaCollectionScreen extends StatefulWidget {
  const MediaCollectionScreen({super.key});

  @override
  State<MediaCollectionScreen> createState() => _MediaCollectionScreenState();
}

class _MediaCollectionScreenState extends State<MediaCollectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showMediaSourceSheet(BuildContext context, {required bool isVideo}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<MediaBloc>(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.dividerDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isVideo ? 'Add Video' : 'Add Image',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              _SourceOption(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  if (isVideo) {
                    context
                        .read<MediaBloc>()
                        .add(const MediaPickVideoFromCamera());
                  } else {
                    context
                        .read<MediaBloc>()
                        .add(const MediaPickFromCamera());
                  }
                },
              ),
              const SizedBox(height: 12),
              _SourceOption(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: () {
                  Navigator.pop(context);
                  if (isVideo) {
                    context
                        .read<MediaBloc>()
                        .add(const MediaPickVideoFromGallery());
                  } else {
                    context
                        .read<MediaBloc>()
                        .add(const MediaPickFromGallery());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(BuildContext context) async {
    setState(() => _isSaving = true);

    // Capture all context-dependent refs BEFORE the async gap
    final mediaBloc = context.read<MediaBloc>();
    final feedbackCubit = context.read<FeedbackCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      final mediaState = mediaBloc.state;

      // Update media paths in cubit
      feedbackCubit.setMediaPaths(mediaState.filePaths);

      // Build final FeedbackModel and insert into DB
      final feedback = feedbackCubit.state.toFeedbackModel();
      await getIt<DatabaseService>().insertFeedback(feedback);

      // Reset media BLoC for next entry
      if (mounted) mediaBloc.add(const MediaReset());

      // Navigate to Thank You screen
      if (mounted) router.go(AppConstants.thankYouRoute);
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save feedback: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<MediaBloc, MediaState>(
      listener: (context, state) {
        if (state.status == MediaStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 28),
                        _buildAddButtons(context),
                        const SizedBox(height: 24),
                        _buildMediaGrid(context),
                      ],
                    ),
                  ),
                ),
                _buildSubmitButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textSecondary),
        onPressed: () => context.go(AppConstants.bugDescriptionRoute),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildStepIndicator(currentStep: 3),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'STEP 3 OF 3',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Media Collection',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Attach screenshots, images, or videos related to the issue. (Optional)',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AddMediaButton(
            icon: Icons.image_rounded,
            label: 'Add Image',
            color: AppTheme.primaryColor,
            onTap: () => _showMediaSourceSheet(context, isVideo: false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AddMediaButton(
            icon: Icons.videocam_rounded,
            label: 'Add Video',
            color: AppTheme.accentColor,
            onTap: () => _showMediaSourceSheet(context, isVideo: true),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaGrid(BuildContext context) {
    return BlocBuilder<MediaBloc, MediaState>(
      builder: (context, state) {
        if (state.files.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.perm_media_outlined,
                    size: 56,
                    color: AppTheme.textHint.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No media attached yet',
                    style: TextStyle(
                      color: AppTheme.textHint,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.status == MediaStatus.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: state.files.length,
          itemBuilder: (context, index) {
            final file = state.files[index];
            return _MediaThumbnail(
              file: file,
              onRemove: () {
                context.read<MediaBloc>().add(MediaRemoved(file.path));
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _isSaving ? null : () => _onSubmit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator({required int currentStep}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isCurrent = i == currentStep - 1;
        final isDone = i < currentStep - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 20 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isDone || isCurrent
                ? AppTheme.primaryColor
                : AppTheme.dividerDark,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _AddMediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AddMediaButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  final MediaFile file;
  final VoidCallback onRemove;

  const _MediaThumbnail({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: file.isVideo
              ? Container(
                  color: AppTheme.cardDark,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: AppTheme.accentColor,
                      size: 36,
                    ),
                  ),
                )
              : Image.file(
                  File(file.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.cardDark,
                    child: const Icon(Icons.broken_image_rounded,
                        color: AppTheme.textHint),
                  ),
                ),
        ),
        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 14),
            ),
          ),
        ),
        // Video indicator badge
        if (file.isVideo)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VIDEO',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}
