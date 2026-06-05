// lib/features/user_details/bloc/user_details_event.dart

import 'package:equatable/equatable.dart';

abstract class UserDetailsEvent extends Equatable {
  const UserDetailsEvent();

  @override
  List<Object?> get props => [];
}

class UserDetailsNameChanged extends UserDetailsEvent {
  final String name;
  const UserDetailsNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class UserDetailsEmailChanged extends UserDetailsEvent {
  final String email;
  const UserDetailsEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class UserDetailsContactChanged extends UserDetailsEvent {
  final String contact;
  const UserDetailsContactChanged(this.contact);

  @override
  List<Object?> get props => [contact];
}

class UserDetailsSubmitted extends UserDetailsEvent {
  const UserDetailsSubmitted();
}

class UserDetailsReset extends UserDetailsEvent {
  const UserDetailsReset();
}
