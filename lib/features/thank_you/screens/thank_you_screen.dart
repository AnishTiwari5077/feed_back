// lib/features/thank_you/screens/thank_you_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/export/bloc/export_bloc.dart';
import '../../../features/export/bloc/export_event.dart';
import '../../../features/export/bloc/export_state.dart';
import '../../../features/feedback_cubit/feedback_cubit.dart';
import '../../../features/user_details/bloc/user_details_bloc.dart';
import '../../../features/user_details/bloc/user_details_event.dart';
import '../../../features/bug_description/bloc/bug_bloc.dart';
import '../../../features/bug_description/bloc/bug_event.dart';

/// Screen 5 — Thank You
/// Shows animated success checkmark.
/// Auto-redirects back to Screen 2 (User Details) after [AppConstants.thankYouRedirectDelay]
/// seconds to accept another entry — exactly as specified in IMPLEMENTATION.md.
/// Countdown is CANCELLED if user taps Export or Add Another Entry buttons.
class ThankYouScreen extends StatefulWidget {
  const ThankYouScreen({super.key});

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _pulseController;
  late AnimationController _contentController;

  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  late Animation<double> _pulseAnim;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  int _countdown = AppConstants.thankYouRedirectDelay;
  Timer? _countdownTimer;
  bool _countdownCancelled = false;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    _checkOpacity = CurvedAnimation(
      parent: _checkController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    // Start animations sequentially
    _checkController.forward().then((_) {
      _pulseController.repeat(reverse: true);
      _contentController.forward();
    });

    // Start countdown — fires every 1 second
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        _navigateToUserDetails();
      }
    });
  }

  /// Cancel the auto-redirect countdown (called when user taps a button).
  void _cancelCountdown() {
    _countdownTimer?.cancel();
    if (!mounted) return;
    setState(() => _countdownCancelled = true);
  }

  void _navigateToUserDetails() {
    _countdownTimer?.cancel();
    if (!mounted) return;
    // Reset all form BLoCs for next entry
    context.read<FeedbackCubit>().reset();
    context.read<UserDetailsBloc>().add(const UserDetailsReset());
    context.read<BugBloc>().add(const BugReset());
    // Navigate back to Screen 2 to accept another entry
    context.go(AppConstants.userDetailsRoute);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _checkController.dispose();
    _pulseController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportBloc, ExportState>(
      listener: (context, state) {
        if (state is ExportSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E2A3A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.accentColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is ExportFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else if (state is ExportAuthFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication failed. Cannot export data.'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated success checkmark
                ScaleTransition(
                  scale: _checkScale,
                  child: FadeTransition(
                    opacity: _checkOpacity,
                    child: ScaleTransition(
                      scale: _pulseAnim,
                      child: _buildSuccessIcon(),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Content (fades in after checkmark)
                FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: Column(
                      children: [
                        const Text(
                          'Feedback Submitted\nSuccessfully!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            height: 1.2,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Thank you for helping us improve.\nYour feedback has been saved to the local database.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Countdown OR cancelled indicator
                        _buildCountdownIndicator(),

                        const SizedBox(height: 28),

                        // Export CSV button — cancels countdown when tapped
                        _buildExportButton(context),
                        const SizedBox(height: 14),

                        // Add another entry now — cancels countdown and navigates immediately
                        TextButton.icon(
                          onPressed: () {
                            _cancelCountdown();
                            _navigateToUserDetails();
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          label: const Text(
                            'Add another entry now →',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.accentColor, Color(0xFF00B894)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 64,
      ),
    );
  }

  Widget _buildCountdownIndicator() {
    if (_countdownCancelled) {
      // Show a persistent indicator that the redirect was cancelled
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerDark),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pause_circle_outline_rounded,
                size: 18, color: AppTheme.textHint),
            SizedBox(width: 8),
            Text(
              'Auto-redirect paused',
              style: TextStyle(
                color: AppTheme.textHint,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: _countdown / AppConstants.thankYouRedirectDelay,
              strokeWidth: 2.5,
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.dividerDark,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Redirecting in $_countdown second${_countdown != 1 ? 's' : ''}...',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          // Tap to cancel redirect
          GestureDetector(
            onTap: _cancelCountdown,
            child: const Icon(
              Icons.cancel_outlined,
              size: 18,
              color: AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return BlocBuilder<ExportBloc, ExportState>(
      builder: (context, state) {
        final isLoading =
            state is ExportAuthenticating || state is ExportLoading;
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    // Cancel the auto-redirect so user can wait for export result
                    _cancelCountdown();
                    context.read<ExportBloc>().add(const ExportCsvRequested());
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor,
                    ),
                  )
                : const Icon(Icons.download_rounded, size: 20),
            label: Text(
              isLoading
                  ? (state is ExportAuthenticating
                      ? 'Authenticating...'
                      : 'Exporting...')
                  : 'Export All as CSV',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }
}
