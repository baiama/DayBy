import 'package:flutter/foundation.dart';

@immutable
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.date,
    this.listId,
    this.important = false,
    this.done = false,
  });

  final String id;
  final String title;
  final DateTime date;
  final String? listId;
  final bool important;
  final bool done;

  Task copyWith({
    String? title,
    DateTime? date,
    String? listId,
    bool? important,
    bool? done,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        date: date ?? this.date,
        listId: listId ?? this.listId,
        important: important ?? this.important,
        done: done ?? this.done,
      );
}

@immutable
class TaskList {
  const TaskList({required this.id, required this.name, required this.emoji});

  final String id;
  final String name;
  final String emoji;
}
