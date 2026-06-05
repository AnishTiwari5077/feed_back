// lib/features/auth/bloc/auth_event.dart

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the user taps "Sign in with Google".
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// Triggered when the user taps "Sign Out".
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Triggered on app start to check for an existing auth session.
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}
