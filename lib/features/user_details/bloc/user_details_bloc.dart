// lib/features/user_details/bloc/user_details_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_details_event.dart';
import 'user_details_state.dart';

class UserDetailsBloc extends Bloc<UserDetailsEvent, UserDetailsState> {
  UserDetailsBloc() : super(const UserDetailsState()) {
    on<UserDetailsNameChanged>(_onNameChanged);
    on<UserDetailsEmailChanged>(_onEmailChanged);
    on<UserDetailsContactChanged>(_onContactChanged);
    on<UserDetailsSubmitted>(_onSubmitted);
    on<UserDetailsReset>(_onReset);
  }

  void _onNameChanged(
    UserDetailsNameChanged event,
    Emitter<UserDetailsState> emit,
  ) {
    final error = _validateName(event.name);
    emit(state.copyWith(
      name: event.name,
      nameError: error,
      clearNameError: error == null,
    ));
  }

  void _onEmailChanged(
    UserDetailsEmailChanged event,
    Emitter<UserDetailsState> emit,
  ) {
    final error = _validateEmail(event.email);
    emit(state.copyWith(
      email: event.email,
      emailError: error,
      clearEmailError: error == null,
    ));
  }

  void _onContactChanged(
    UserDetailsContactChanged event,
    Emitter<UserDetailsState> emit,
  ) {
    final error = _validateContact(event.contact);
    emit(state.copyWith(
      contact: event.contact,
      contactError: error,
      clearContactError: error == null,
    ));
  }

  void _onSubmitted(
    UserDetailsSubmitted event,
    Emitter<UserDetailsState> emit,
  ) {
    final nameError = _validateName(state.name);
    final emailError = _validateEmail(state.email);
    final contactError = _validateContact(state.contact);

    if (nameError != null || emailError != null || contactError != null) {
      emit(state.copyWith(
        nameError: nameError,
        emailError: emailError,
        contactError: contactError,
        status: UserDetailsStatus.invalid,
      ));
      return;
    }
    emit(state.copyWith(status: UserDetailsStatus.success));
  }

  void _onReset(UserDetailsReset event, Emitter<UserDetailsState> emit) {
    emit(const UserDetailsState());
  }

  String? _validateName(String name) {
    if (name.trim().isEmpty) return 'Full name is required';
    if (name.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String email) {
    if (email.trim().isEmpty) return 'Email address is required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validateContact(String contact) {
    if (contact.trim().isEmpty) return 'Contact number is required';
    final digits = contact.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return 'Enter a valid contact number';
    return null;
  }
}
