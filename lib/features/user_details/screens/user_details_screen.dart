// lib/features/user_details/screens/user_details_screen.dart

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
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
      setState(() {
        _deviceModel = 'Unknown Device';
      });
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundDark,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        TextButton.icon(
          onPressed: () {
            context.read<AuthBloc>().add(const SignOutRequested());
            context.go(AppConstants.loginRoute);
          },
          icon: const Icon(
            Icons.logout_rounded,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          label: const Text(
            'Sign out',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildStepIndicator(currentStep: 1),
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

  Widget _buildDeviceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.2)),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
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
    widget.focusNode.addListener(() {
      setState(() => _isFocused = widget.focusNode.hasFocus);
    });
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
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
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
