import 'package:dayby/features/auth/validators.dart';
import 'package:dayby/features/tasks/tasks_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TasksNotifier', () {
    test('toggle flips done and updates today progress', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final before = container.read(todayProgressProvider);
      final open = container.read(todayTasksProvider).firstWhere((t) => !t.done);
      container.read(tasksProvider.notifier).toggle(open.id);
      expect(container.read(todayProgressProvider), greaterThan(before));
    });

    test('add and remove', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(tasksProvider.notifier);
      final count = container.read(tasksProvider).length;
      notifier.add(title: 'Новая', date: DateTime.now(), important: true);
      final added = container.read(tasksProvider).last;
      expect(added.title, 'Новая');
      expect(added.important, isTrue);
      notifier.remove(added.id);
      expect(container.read(tasksProvider).length, count);
    });
  });

  group('validators', () {
    test('email', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail('user@'), isNotNull);
      expect(validateEmail('user@mail.com'), isNull);
    });

    test('password', () {
      expect(validatePassword('123'), isNotNull);
      expect(validatePassword('123456'), isNull);
    });
  });
}
