import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/test_id.dart';
import '../settings/settings_provider.dart';
import 'task_editor_sheet.dart';
import 'task_tile.dart';
import 'tasks_provider.dart';

/// «Главная»: today's progress and important tasks.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final progress = ref.watch(todayProgressProvider);
    final allToday = ref.watch(todayTasksProvider);
    final showCompleted = ref.watch(settingsProvider.select((s) => s.showCompleted));
    final today = showCompleted ? allToday : allToday.where((t) => !t.done).toList();
    final important = today.where((t) => t.important).toList();
    final rest = today.where((t) => !t.important).toList();
    final allDone = allToday.isNotEmpty && allToday.every((t) => t.done);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TestId(
                'home_progress',
                keepChildren: true,
                child: Container(
                  width: 149,
                  height: 149,
                  decoration: BoxDecoration(
                    color: c.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: ProgressRing(
                    value: progress,
                    color: c.text,
                    trackColor: c.accent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).round()}%',
                          style: AppText.logo(c.text).copyWith(fontSize: 24),
                        ),
                        Text(
                          'Выполнено',
                          style: AppText.button(c.text)
                              .copyWith(fontSize: 8, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Semantics(
                  identifier: 'home_search',
                  container: true,
                  label: 'Поиск',
                  button: true,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.push('/search'),
                    child: CircleAvatar(
                      radius: 17.5,
                      backgroundColor: c.accent.withValues(alpha: 0.2),
                      child: Icon(Icons.search, color: c.text, size: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Semantics(
                  identifier: 'home_profile',
                  container: true,
                  label: 'Профиль',
                  button: true,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.push('/profile'),
                    child: CircleAvatar(
                      radius: 17.5,
                      backgroundColor: c.text,
                      child: Icon(Icons.person, color: c.background, size: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          if (allToday.isEmpty)
            EmptyState(
              testId: 'home_empty',
              icon: Icons.wb_sunny_outlined,
              title: 'На сегодня планов нет',
              message: 'Добавьте первую задачу, и день начнёт обретать форму.',
              actionLabel: 'Добавить задачу',
              onAction: () => showTaskEditor(context),
            )
          else ...[
            if (allDone) ...[const _AllDoneBanner(), const SizedBox(height: 24)],
            Text('Важные задачи', style: AppText.section(c.text)),
            const SizedBox(height: 16),
            if (important.isEmpty)
              const TestId(
                'home_important_empty',
                child: _Empty(text: 'Нет важных задач на сегодня'),
              )
            else
              for (final t in important) TaskTile(task: t),
            if (rest.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Остальные', style: AppText.h3(c.text)),
              const SizedBox(height: 8),
              for (final t in rest) TaskTile(task: t),
            ],
          ],
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Text(text, style: AppText.body(context.colors.muted)),
  );
}

class _AllDoneBanner extends StatelessWidget {
  const _AllDoneBanner();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TestId(
      'home_all_done',
      keepChildren: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.accent.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Все задачи на сегодня выполнены', style: AppText.label(Colors.white)),
                  const SizedBox(height: 2),
                  Text('Отличный день! Можно отдохнуть.', style: AppText.body(Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
