import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// In-memory task store with demo data. Will be backed by Firestore later.
final tasksProvider =
    NotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

class TasksNotifier extends Notifier<List<Task>> {
  int _nextId = 100;

  @override
  List<Task> build() {
    final today = dateOnly(DateTime.now());
    DateTime day(int offset) => today.add(Duration(days: offset));
    return [
      Task(id: '1', title: 'Сдать отчёт по проекту', date: day(0), listId: 'work', important: true, done: true),
      Task(id: '2', title: 'Позвонить маме', date: day(0), listId: 'personal', important: true, done: true),
      Task(id: '3', title: 'Купить продукты на неделю', date: day(0), listId: 'shopping', important: true, done: true),
      Task(id: '4', title: 'Записаться к стоматологу', date: day(0), listId: 'personal', important: true),
      Task(id: '5', title: 'Ответить на письма', date: day(0), listId: 'work'),
      Task(id: '6', title: 'Тренировка', date: day(1), listId: 'personal', important: true),
      Task(id: '7', title: 'Созвон с командой', date: day(1), listId: 'work'),
      Task(id: '8', title: 'Молоко, хлеб, яйца', date: day(2), listId: 'shopping'),
      Task(id: '9', title: 'Подготовить презентацию', date: day(-1), listId: 'work', important: true, done: true),
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

  void update(Task task) =>
      state = [for (final t in state) t.id == task.id ? task : t];

  void toggle(String id) => state = [
        for (final t in state) t.id == id ? t.copyWith(done: !t.done) : t,
      ];

  void remove(String id) => state = state.where((t) => t.id != id).toList();
}

final listsProvider = Provider<List<TaskList>>((ref) => const [
      TaskList(id: 'work', name: 'Работа', emoji: '💼'),
      TaskList(id: 'personal', name: 'Личное', emoji: '🌸'),
      TaskList(id: 'shopping', name: 'Покупки', emoji: '🛒'),
    ]);

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
