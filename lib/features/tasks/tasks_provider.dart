import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// In-memory task store with demo data. Will be backed by Firestore later.
final tasksProvider = NotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

class TasksNotifier extends Notifier<List<Task>> {
  int _nextId = 100;

  @override
  List<Task> build() {
    final today = dateOnly(DateTime.now());
    DateTime day(int offset) => today.add(Duration(days: offset));
    return [
      Task(
        id: '1',
        title: 'Сдать отчёт по проекту',
        date: day(0),
        listId: 'work',
        important: true,
        done: true,
        note: 'Финальная версия в общей папке, отправить Ане до обеда.',
        subtasks: const [
          Subtask(id: '1a', title: 'Собрать цифры за месяц', done: true),
          Subtask(id: '1b', title: 'Сверстать слайды', done: true),
        ],
      ),
      Task(
        id: '2',
        title: 'Позвонить маме',
        date: day(0),
        listId: 'personal',
        important: true,
        done: true,
      ),
      Task(
        id: '3',
        title: 'Купить продукты на неделю',
        date: day(0),
        listId: 'shopping',
        important: true,
        done: true,
      ),
      Task(
        id: '4',
        title: 'Записаться к стоматологу',
        date: day(0),
        listId: 'personal',
        important: true,
        reminder: const TimeOfDay(hour: 18, minute: 0),
        note: 'Клиника на Ленина, 12. Спросить про чистку.',
      ),
      Task(id: '5', title: 'Ответить на письма', date: day(0), listId: 'work'),
      Task(
        id: '6',
        title: 'Тренировка',
        date: day(1),
        listId: 'personal',
        important: true,
        repeat: Repeat.weekly,
        reminder: const TimeOfDay(hour: 7, minute: 30),
      ),
      Task(id: '7', title: 'Созвон с командой', date: day(1), listId: 'work'),
      Task(
        id: '8',
        title: 'Молоко, хлеб, яйца',
        date: day(2),
        listId: 'shopping',
        subtasks: const [
          Subtask(id: '8a', title: 'Молоко'),
          Subtask(id: '8b', title: 'Хлеб', done: true),
          Subtask(id: '8c', title: 'Яйца'),
        ],
      ),
      Task(
        id: '9',
        title: 'Подготовить презентацию',
        date: day(-1),
        listId: 'work',
        important: true,
        done: true,
      ),
      Task(id: '10', title: 'Прочитать главу книги', date: day(-2), listId: 'personal', done: true),
      Task(id: '11', title: 'Оплатить интернет', date: day(-3), listId: 'personal', done: true),
      Task(id: '12', title: 'Ревью кода', date: day(-3), listId: 'work'),
    ];
  }

  void add({
    required String title,
    required DateTime date,
    String? listId,
    bool important = false,
  }) {
    state = [
      ...state,
      Task(
        id: '${_nextId++}',
        title: title,
        date: dateOnly(date),
        listId: listId,
        important: important,
      ),
    ];
  }

  String _id() => '${_nextId++}';

  Task? byId(String id) => state.where((t) => t.id == id).firstOrNull;

  void _edit(String id, Task Function(Task) change) =>
      state = [for (final t in state) t.id == id ? change(t) : t];

  void addSubtask(String taskId, String title) => _edit(
    taskId,
    (t) => t.copyWith(
      subtasks: [
        ...t.subtasks,
        Subtask(id: 's${_id()}', title: title),
      ],
    ),
  );

  void toggleSubtask(String taskId, String subId) => _edit(
    taskId,
    (t) => t.copyWith(
      subtasks: [for (final s in t.subtasks) s.id == subId ? s.copyWith(done: !s.done) : s],
    ),
  );

  void removeSubtask(String taskId, String subId) =>
      _edit(taskId, (t) => t.copyWith(subtasks: t.subtasks.where((s) => s.id != subId).toList()));

  /// Puts a removed task back where it was (for «Отменить» snackbars).
  void restore(Task task, int index) {
    final next = [...state];
    next.insert(index.clamp(0, next.length), task);
    state = next;
  }

  /// Tasks of a deleted list stay, without a list.
  void detachList(String listId) =>
      state = [for (final t in state) t.listId == listId ? t.copyWith(listId: null) : t];

  void removeDone() => state = state.where((t) => !t.done).toList();

  void update(Task task) => state = [for (final t in state) t.id == task.id ? task : t];

  void toggle(String id) =>
      state = [for (final t in state) t.id == id ? t.copyWith(done: !t.done) : t];

  void remove(String id) => state = state.where((t) => t.id != id).toList();
}

final listsProvider = NotifierProvider<ListsNotifier, List<TaskList>>(ListsNotifier.new);

class ListsNotifier extends Notifier<List<TaskList>> {
  int _nextId = 1;

  @override
  List<TaskList> build() => const [
    TaskList(id: 'work', name: 'Работа', emoji: '💼'),
    TaskList(id: 'personal', name: 'Личное', emoji: '🌸'),
    TaskList(id: 'shopping', name: 'Покупки', emoji: '🛒'),
  ];

  /// Returns the new list's id.
  String add(String name, String emoji) {
    final id = 'custom${_nextId++}';
    state = [...state, TaskList(id: id, name: name, emoji: emoji)];
    return id;
  }

  void rename(String id, String name, String emoji) =>
      state = [for (final l in state) l.id == id ? TaskList(id: id, name: name, emoji: emoji) : l];

  void remove(String id) => state = state.where((l) => l.id != id).toList();
}

final todayTasksProvider = Provider<List<Task>>((ref) {
  final now = DateTime.now();
  return ref.watch(tasksProvider).where((t) => isSameDay(t.date, now)).toList();
});

/// Share of today's tasks that are done, 0..1.
final todayProgressProvider = Provider<double>((ref) {
  final today = ref.watch(todayTasksProvider);
  if (today.isEmpty) return 0;
  return today.where((t) => t.done).length / today.length;
});
