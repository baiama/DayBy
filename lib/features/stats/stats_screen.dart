import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/test_id.dart';
import '../calendar/week_strip.dart';
import '../tasks/tasks_provider.dart';

/// «Статистика». Not in the Figma file yet; built from existing pieces.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final tasks = ref.watch(tasksProvider);
    final total = tasks.length;
    final done = tasks.where((t) => t.done).length;
    final today = dateOnly(DateTime.now());
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final perDay = [
      for (var i = 0; i < 7; i++)
        tasks.where((t) => t.done && isSameDay(t.date, weekStart.add(Duration(days: i)))).length,
    ];
    final maxPerDay = perDay.fold<int>(1, (m, v) => v > m ? v : m);

    Widget card({required Widget child}) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(28)),
      child: child,
    );

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
        children: [
          Text('Статистика', style: AppText.h1(c.text)),
          const SizedBox(height: 24),
          card(
            child: Row(
              children: [
                ProgressRing(
                  value: total == 0 ? 0 : done / total,
                  color: c.text,
                  trackColor: c.accent,
                  size: 96,
                  child: Text(
                    total == 0 ? '0%' : '${(done * 100 / total).round()}%',
                    style: AppText.logo(c.text).copyWith(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TestId(
                        'stats_total',
                        child: Text('Всего задач: $total', style: AppText.setting(c.text)),
                      ),
                      const SizedBox(height: 6),
                      TestId(
                        'stats_done',
                        child: Text('Выполнено: $done', style: AppText.setting(c.text)),
                      ),
                      const SizedBox(height: 6),
                      TestId(
                        'stats_left',
                        child: Text('Осталось: ${total - done}', style: AppText.setting(c.muted)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Выполнено за неделю', style: AppText.h3(c.text)),
                const SizedBox(height: 20),
                TestId(
                  'stats_week_chart',
                  child: SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < 7; i++)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('${perDay[i]}', style: AppText.mono(c.text, size: 11)),
                                const SizedBox(height: 4),
                                // Flexible lets the tallest bar give up a few px when
                                // larger text eats into the 140 px, instead of overflowing.
                                Flexible(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    height: 4 + 96 * perDay[i] / maxPerDay,
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: isSameDay(weekStart.add(Duration(days: i)), today)
                                          ? c.accent
                                          : c.accent.withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(weekdayShort[i], style: AppText.mono(c.muted, size: 11)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
