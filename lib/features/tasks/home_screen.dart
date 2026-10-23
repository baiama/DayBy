import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/progress_ring.dart';
import 'task_tile.dart';
import 'tasks_provider.dart';

/// «Главная»: today's progress and important tasks.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final progress = ref.watch(todayProgressProvider);
    final today = ref.watch(todayTasksProvider);
    final important = today.where((t) => t.important).toList();
    final rest = today.where((t) => !t.important).toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Semantics(
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
          Text('Важные задачи', style: AppText.section(c.text)),
          const SizedBox(height: 16),
          if (important.isEmpty)
            _Empty(text: 'Нет важных задач на сегодня')
          else
            for (final t in important) TaskTile(task: t),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Остальные', style: AppText.h3(c.text)),
            const SizedBox(height: 8),
            for (final t in rest) TaskTile(task: t),
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
