// lib/features/user_details/screens/user_details_screen.dart

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../features/feedback_cubit/feedback_cubit.dart';
import '../bloc/user_details_bloc.dart';
import '../bloc/user_details_event.dart';
import '../bloc/user_details_state.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _contactFocus = FocusNode();

  String? _deviceModel;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
    _detectDevice();
  }

  Future<void> _detectDevice() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      setState(() {
        _deviceModel = '${androidInfo.manufacturer} ${androidInfo.model} '
            '(Android ${androidInfo.version.release})';
      });
    } catch (_) {
      setState(() => _deviceModel = 'Unknown Device');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _contactFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────
  String _initials(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) return 'U';
    return displayName
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase())
        .take(2)
        .join();
  }

  // ── build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocListener<UserDetailsBloc, UserDetailsState>(
      listener: (context, state) {
        if (state.status == UserDetailsStatus.success) {
          context.read<FeedbackCubit>().setUserDetails(
                name: state.name,
                email: state.email,
                contact: state.contact,
                userDevice: _deviceModel,
              );
          context.go(AppConstants.bugDescriptionRoute);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildDeviceInfoCard(),
                  const SizedBox(height: 28),
                  _buildForm(),
                  const SizedBox(height: 32),
                  _buildNextButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────
  AppBar _buildAppBar(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return AppBar(
      backgroundColor: AppTheme.backgroundDark,
      elevation: 0,
      automaticallyImplyLeading: false,
      // ── left side: avatar + name/email ──
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar — photo if available, else initials
          CircleAvatar(
            radius: 16,
            backgroundImage:
                user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            backgroundColor: AppTheme.primaryColor,
            child: user?.photoURL == null
                ? Text(
                    _initials(user?.displayName),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      // ── right side: sign-out + step indicator ──
      actions: [
        _SignOutButton(context: context),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildStepIndicator(currentStep: 1),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────
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
            'STEP 1 OF 3',
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
          'User Details',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tell us about the person submitting this feedback.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Device info card ──────────────────────────────────────────
  Widget _buildDeviceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_android_rounded,
              color: AppTheme.accentColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Device Auto-Detected',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _deviceModel ?? 'Detecting...',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Form ──────────────────────────────────────────────────────
  Widget _buildForm() {
    return BlocBuilder<UserDetailsBloc, UserDetailsState>(
      builder: (context, state) {
        return Column(
          children: [
            _AnimatedFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              label: 'Full Name',
              hint: 'e.g. John Doe',
              icon: Icons.person_outline_rounded,
              errorText: state.nameError,
              onChanged: (v) => context
                  .read<UserDetailsBloc>()
                  .add(UserDetailsNameChanged(v)),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            ),
            const SizedBox(height: 16),
            _AnimatedFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              label: 'Email Address',
              hint: 'e.g. john@example.com',
              icon: Icons.email_outlined,
              errorText: state.emailError,
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => context
                  .read<UserDetailsBloc>()
                  .add(UserDetailsEmailChanged(v)),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _contactFocus.requestFocus(),
            ),
            const SizedBox(height: 16),
            _AnimatedFormField(
              controller: _contactController,
              focusNode: _contactFocus,
              label: 'Contact Number',
              hint: 'e.g. +1 555 000 0000',
              icon: Icons.phone_outlined,
              errorText: state.contactError,
              keyboardType: TextInputType.phone,
              onChanged: (v) => context
                  .read<UserDetailsBloc>()
                  .add(UserDetailsContactChanged(v)),
              textInputAction: TextInputAction.done,
            ),
          ],
        );
      },
    );
  }

  // ── Next button ───────────────────────────────────────────────
  Widget _buildNextButton() {
    return BlocBuilder<UserDetailsBloc, UserDetailsState>(
      builder: (context, state) {
        final isLoading = state.status == UserDetailsStatus.submitting;
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    context
                        .read<UserDetailsBloc>()
                        .add(const UserDetailsSubmitted());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              disabledBackgroundColor:
                  AppTheme.primaryColor.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // ── Step indicator ────────────────────────────────────────────
  Widget _buildStepIndicator({required int currentStep}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isActive = i < currentStep;
        final isCurrent = i == currentStep - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 20 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive || isCurrent
                ? AppTheme.primaryColor
                : AppTheme.dividerDark,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// SIGN OUT BUTTON — professional with confirmation dialog
// ════════════════════════════════════════════════════════════════
class _SignOutButton extends StatelessWidget {
  final BuildContext context;
  const _SignOutButton({required this.context});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showSignOutDialog(context),
      icon: const Icon(
        Icons.logout_rounded,
        size: 15,
        color: Color(0xFFF87171),
      ),
      label: const Text(
        'Sign out',
        style: TextStyle(
          color: Color(0xFFF87171),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.08),
        side: const BorderSide(
          color: Color(0xFFEF4444),
          width: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon circle ──
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFF87171),
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            // ── Title ──
            const Text(
              'Sign out?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // ── Body ──
            const Text(
              'You will be redirected to the login screen. '
              'Any unsaved progress will be lost.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.55,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              // ── Cancel ──
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // ── Confirm sign out ──
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<AuthBloc>().add(const SignOutRequested());
                    context.go(AppConstants.loginRoute);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign out',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ANIMATED FORM FIELD
// ════════════════════════════════════════════════════════════════
class _AnimatedFormField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const _AnimatedFormField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    this.errorText,
    this.keyboardType,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<_AnimatedFormField> createState() => _AnimatedFormFieldState();
}

class _AnimatedFormFieldState extends State<_AnimatedFormField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: Icon(
            widget.icon,
            color: _isFocused ? AppTheme.primaryColor : AppTheme.textHint,
            size: 20,
          ),
          errorText: widget.errorText,
          errorStyle: const TextStyle(
            color: AppTheme.errorColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
