

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/feedback_cubit/feedback_cubit.dart';
import '../bloc/bug_bloc.dart';
import '../bloc/bug_event.dart';
import '../bloc/bug_state.dart';


class BugDescriptionScreen extends StatefulWidget {
  const BugDescriptionScreen({super.key});

  @override
  State<BugDescriptionScreen> createState() => _BugDescriptionScreenState();
}

class _BugDescriptionScreenState extends State<BugDescriptionScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _titleFocus = FocusNode();
  final _descFocus = FocusNode();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BugBloc, BugState>(
      listener: (context, state) {
        if (state.status == BugStatus.success) {
          context.read<FeedbackCubit>().setBugDetails(
                bugIssue: state.title,
                description: state.description,
              );
          context.go(AppConstants.mediaCollectionRoute);
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
                  _buildForm(context),
                  const SizedBox(height: 32),
                  _buildNextButton(context),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textSecondary),
        onPressed: () => context.go(AppConstants.userDetailsRoute),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildStepIndicator(currentStep: 2),
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
            'STEP 2 OF 3',
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
          'Bug Description',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Describe the issue or bug encountered in detail.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return BlocBuilder<BugBloc, BugState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFocusableField(
              controller: _titleController,
              focusNode: _titleFocus,
              label: 'Bug / Issue Title',
              hint: 'e.g. App crashes on login',
              icon: Icons.bug_report_outlined,
              errorText: state.titleError,
              maxLength: AppConstants.bugTitleMaxLength,
              onChanged: (v) =>
                  context.read<BugBloc>().add(BugTitleChanged(v)),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _descFocus.requestFocus(),
            ),
            const SizedBox(height: 20),
            _buildFocusableField(
              controller: _descController,
              focusNode: _descFocus,
              label: 'Detailed Description',
              hint:
                  'Describe exactly what happened, steps to reproduce, expected vs actual behavior...',
              icon: Icons.description_outlined,
              errorText: state.descriptionError,
              maxLength: AppConstants.descriptionMaxLength,
              maxLines: 6,
              onChanged: (v) =>
                  context.read<BugBloc>().add(BugDescriptionChanged(v)),
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${state.descriptionLength} / ${AppConstants.descriptionMaxLength}',
                style: TextStyle(
                  color: state.descriptionLength >
                          AppConstants.descriptionMaxLength * 0.9
                      ? AppTheme.warningColor
                      : AppTheme.textHint,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFocusableField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    String? errorText,
    int? maxLength,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return Focus(
      focusNode: focusNode,
      child: Builder(
        builder: (ctx) {
          final isFocused = Focus.of(ctx).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: isFocused
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
              controller: controller,
              maxLines: maxLines,
              maxLength: maxLength,
              textInputAction: textInputAction,
              onChanged: onChanged,
              onFieldSubmitted: onFieldSubmitted,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppTheme.textHint,
                  fontSize: 13,
                  height: 1.5,
                ),
                alignLabelWithHint: maxLines > 1,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: maxLines > 1 ? 60 : 0),
                  child: Icon(icon, color: AppTheme.textHint, size: 20),
                ),
                errorText: errorText,
                errorStyle: const TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return BlocBuilder<BugBloc, BugState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              context.read<BugBloc>().add(const BugSubmitted());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
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
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
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
