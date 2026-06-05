// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/user_details/screens/user_details_screen.dart';
import '../../features/bug_description/screens/bug_description_screen.dart';
import '../../features/media_collection/screens/media_collection_screen.dart';
import '../../features/thank_you/screens/thank_you_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.loginRoute,
  routes: [
    GoRoute(
      path: AppConstants.loginRoute,
      name: 'login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionsBuilder: _slideTransition,
      ),
    ),
    GoRoute(
      path: AppConstants.userDetailsRoute,
      name: 'user-details',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const UserDetailsScreen(),
        transitionsBuilder: _slideTransition,
      ),
    ),
    GoRoute(
      path: AppConstants.bugDescriptionRoute,
      name: 'bug-description',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const BugDescriptionScreen(),
        transitionsBuilder: _slideTransition,
      ),
    ),
    GoRoute(
      path: AppConstants.mediaCollectionRoute,
      name: 'media-collection',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MediaCollectionScreen(),
        transitionsBuilder: _slideTransition,
      ),
    ),
    GoRoute(
      path: AppConstants.thankYouRoute,
      name: 'thank-you',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ThankYouScreen(),
        transitionsBuilder: _fadeTransition,
      ),
    ),
  ],
);

/// Slide-in from right transition for forward navigation.
Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  const curve = Curves.easeInOutCubic;

  final tween = Tween(begin: begin, end: end)
      .chain(CurveTween(curve: curve));

  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
}

/// Fade transition for the Thank You screen.
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: animation,
    child: child,
  );
}
