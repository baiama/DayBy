import 'package:dayby/core/format.dart';
import 'package:dayby/features/tasks/task.dart';
import 'package:dayby/features/tasks/tasks_provider.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('subtasks', () {
    test('add, toggle, remove', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final n = container.read(tasksProvider.notifier);
      n.addSubtask('5', 'Первое');
      var sub = n.byId('5')!.subtasks.single;
      expect(sub.done, isFalse);
      n.toggleSubtask('5', sub.id);
      expect(n.byId('5')!.subtasks.single.done, isTrue);
      n.removeSubtask('5', sub.id);
      expect(n.byId('5')!.subtasks, isEmpty);
    });
  });

  test('copyWith clears nullable fields only when asked', () {
    final t = Task(
      id: 'x',
      title: 'a',
      date: DateTime(2026),
      listId: 'work',
      reminder: const TimeOfDay(hour: 9, minute: 0),
    );
    expect(t.copyWith(title: 'b').listId, 'work');
    expect(t.copyWith(title: 'b').reminder, isNotNull);
    expect(t.copyWith(listId: null).listId, isNull);
    expect(t.copyWith(reminder: null).reminder, isNull);
  });

  test('restore puts a removed task back in place', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final n = container.read(tasksProvider.notifier);
    final before = container.read(tasksProvider).map((t) => t.id).toList();
    final task = n.byId('3')!;
    final index = before.indexOf('3');
    n.remove('3');
    n.restore(task, index);
    expect(container.read(tasksProvider).map((t) => t.id).toList(), before);
  });

  test('lists: add, rename, delete detaches tasks', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final lists = container.read(listsProvider.notifier);
    final id = lists.add('Дом', '🏠');
    expect(container.read(listsProvider).last.name, 'Дом');
    lists.rename(id, 'Квартира', '🏠');
    expect(container.read(listsProvider).last.name, 'Квартира');

    container.read(tasksProvider.notifier).detachList('work');
    lists.remove('work');
    expect(container.read(listsProvider).any((l) => l.id == 'work'), isFalse);
    expect(container.read(tasksProvider).any((t) => t.listId == 'work'), isFalse);
  });

  test('removeDone keeps only open tasks', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(tasksProvider.notifier).removeDone();
    expect(container.read(tasksProvider).every((t) => !t.done), isTrue);
  });

  group('format', () {
    final now = DateTime(2026, 11, 7, 12);
    test('formatDay', () {
      expect(formatDay(DateTime(2026, 11, 7), now: now), 'Сегодня');
      expect(formatDay(DateTime(2026, 11, 8), now: now), 'Завтра');
      expect(formatDay(DateTime(2026, 11, 6), now: now), 'Вчера');
      expect(formatDay(DateTime(2026, 11, 20), now: now), '20 ноября');
      expect(formatDay(DateTime(2027, 1, 2), now: now), '2 января 2027');
    });

    test('plural', () {
      String p(int n) => plural(n, 'задача', 'задачи', 'задач');
      expect(p(1), 'задача');
      expect(p(3), 'задачи');
      expect(p(5), 'задач');
      expect(p(11), 'задач');
      expect(p(21), 'задача');
      expect(p(112), 'задач');
    });

    test('formatTime', () {
      expect(formatTime(const TimeOfDay(hour: 7, minute: 5)), '07:05');
    });
  });
}
