// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/feedback_cubit/feedback_cubit.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Screen 1 — Google Login
/// Device owner authenticates via Google Sign-In.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    _animationController.forward();

    // Check if already authenticated
    context.read<AuthBloc>().add(const CheckAuthStatus());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Store device owner email in FeedbackCubit
          context.read<FeedbackCubit>().setDeviceOwner(
                state.user.email ?? state.user.uid,
              );
          context.go(AppConstants.userDetailsRoute);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.errorColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppTheme.cardDark,
              action: SnackBarAction(
                label: 'Retry',
                textColor: AppTheme.primaryColor,
                onPressed: () {
                  context.read<AuthBloc>().add(const GoogleSignInRequested());
                },
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Animated App Logo
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildLogo(),
                  ),
                ),
                const SizedBox(height: 48),
                // Animated tagline
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildTagline(),
                  ),
                ),
                const Spacer(),
                // Sign-in button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildSignInButton(context),
                ),
                const SizedBox(height: 40),
                // Footer
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildFooter(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.feedback_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Feedback\nCollector',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            height: 1.1,
            letterSpacing: -1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Collect structured user feedback with\nmedia, organized and exported to CSV.',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        _buildFeatureChip(Icons.shield_rounded, 'Secure Auth'),
        const SizedBox(height: 10),
        _buildFeatureChip(Icons.storage_rounded, 'Local Database'),
        const SizedBox(height: 10),
        _buildFeatureChip(Icons.file_download_rounded, 'CSV Export'),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Column(
          children: [
            // Google Sign-In button
            InkWell(
              onTap: isLoading
                  ? null
                  : () {
                      context
                          .read<AuthBloc>()
                          .add(const GoogleSignInRequested());
                    },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: isLoading
                      ? AppTheme.cardDark
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google Logo
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const _GoogleIcon(),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Sign in with Google',
                            style: TextStyle(
                              color: Color(0xFF1F1F1F),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Only the device owner can access this app\nto collect feedback from users.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.textHint,
          fontSize: 12,
          height: 1.6,
        ),
      ),
    );
  }
}

/// Custom Google 'G' icon painted with correct brand colors.
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GoogleLogoPainter(),
      size: const Size(24, 24),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.35, 1.58, true, paint,
    );
    // Red
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.23, 1.58, true, paint,
    );
    // Yellow
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.81, 1.58, true, paint,
    );
    // Green
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      4.39, 1.58, true, paint,
    );

    // White center hole
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, paint);

    // White 'G' bar (horizontal)
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - radius * 0.18,
          radius * 0.95, radius * 0.36),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter oldDelegate) => false;
}
