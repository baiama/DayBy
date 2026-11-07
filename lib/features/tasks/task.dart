import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;

enum Repeat {
  none('Не повторять', 'нет'),
  daily('Каждый день', 'ежедневно'),
  weekdays('По будням', 'по будням'),
  weekly('Каждую неделю', 'еженедельно'),
  monthly('Каждый месяц', 'ежемесячно');

  const Repeat(this.label, this.short);
  final String label;
  final String short;
}

@immutable
class Subtask {
  const Subtask({required this.id, required this.title, this.done = false});

  final String id;
  final String title;
  final bool done;

  Subtask copyWith({String? title, bool? done}) =>
      Subtask(id: id, title: title ?? this.title, done: done ?? this.done);
}

@immutable
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.date,
    this.listId,
    this.important = false,
    this.done = false,
    this.note = '',
    this.subtasks = const [],
    this.repeat = Repeat.none,
    this.reminder,
  });

  final String id;
  final String title;
  final DateTime date;
  final String? listId;
  final bool important;
  final bool done;
  final String note;
  final List<Subtask> subtasks;
  final Repeat repeat;

  /// Time of day to remind on [date]; null means no reminder.
  final TimeOfDay? reminder;

  /// Sentinel so [copyWith] can clear nullable fields.
  static const _keep = Object();

  Task copyWith({
    String? title,
    DateTime? date,
    Object? listId = _keep,
    bool? important,
    bool? done,
    String? note,
    List<Subtask>? subtasks,
    Repeat? repeat,
    Object? reminder = _keep,
  }) => Task(
    id: id,
    title: title ?? this.title,
    date: date ?? this.date,
    listId: identical(listId, _keep) ? this.listId : listId as String?,
    important: important ?? this.important,
    done: done ?? this.done,
    note: note ?? this.note,
    subtasks: subtasks ?? this.subtasks,
    repeat: repeat ?? this.repeat,
    reminder: identical(reminder, _keep) ? this.reminder : reminder as TimeOfDay?,
  );
}

@immutable
class TaskList {
  const TaskList({required this.id, required this.name, required this.emoji});

  final String id;
  final String name;
  final String emoji;
}
