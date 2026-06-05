// lib/features/user_details/bloc/user_details_state.dart

import 'package:equatable/equatable.dart';

enum UserDetailsStatus { initial, valid, invalid, submitting, success, failure }

class UserDetailsState extends Equatable {
  final String name;
  final String email;
  final String contact;
  final UserDetailsStatus status;
  final String? nameError;
  final String? emailError;
  final String? contactError;
  final String? errorMessage;

  const UserDetailsState({
    this.name = '',
    this.email = '',
    this.contact = '',
    this.status = UserDetailsStatus.initial,
    this.nameError,
    this.emailError,
    this.contactError,
    this.errorMessage,
  });

  bool get isValid =>
      nameError == null &&
      emailError == null &&
      contactError == null &&
      name.isNotEmpty &&
      email.isNotEmpty &&
      contact.isNotEmpty;

  UserDetailsState copyWith({
    String? name,
    String? email,
    String? contact,
    UserDetailsStatus? status,
    String? nameError,
    String? emailError,
    String? contactError,
    String? errorMessage,
    bool clearNameError = false,
    bool clearEmailError = false,
    bool clearContactError = false,
    bool clearErrorMessage = false,
  }) {
    return UserDetailsState(
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      status: status ?? this.status,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      contactError:
          clearContactError ? null : (contactError ?? this.contactError),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        contact,
        status,
        nameError,
        emailError,
        contactError,
        errorMessage,
      ];
}
