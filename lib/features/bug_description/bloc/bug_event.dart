// lib/features/bug_description/bloc/bug_event.dart

import 'package:equatable/equatable.dart';

abstract class BugEvent extends Equatable {
  const BugEvent();

  @override
  List<Object?> get props => [];
}

class BugTitleChanged extends BugEvent {
  final String title;
  const BugTitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class BugDescriptionChanged extends BugEvent {
  final String description;
  const BugDescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class BugSubmitted extends BugEvent {
  const BugSubmitted();
}

class BugReset extends BugEvent {
  const BugReset();
}
