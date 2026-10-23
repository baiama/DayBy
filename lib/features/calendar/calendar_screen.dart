import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../auth/auth_provider.dart';
import '../tasks/task_tile.dart';
import '../tasks/tasks_provider.dart';
import 'week_strip.dart';

const monthsGenitive = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];
const weekdayFull = [
  'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье',
];

String greeting(DateTime now) => switch (now.hour) {
      < 6 => 'Доброй ночи',
      < 12 => 'Доброе утро',
      < 18 => 'Добрый день',
      _ => 'Добрый вечер',
    };

/// Calendar tab: greeting header and week strip from the «Home» draft frame,
/// then the tasks for the selected day.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selected = dateOnly(DateTime.now());

  DateTime get _weekStart =>
      _selected.subtract(Duration(days: _selected.weekday - 1));

  void _shiftWeek(int weeks) =>
      setState(() => _selected = _selected.add(Duration(days: 7 * weeks)));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now();
    final user = ref.watch(authProvider);
    final tasks = ref.watch(tasksProvider);
    final dayTasks = tasks.where((t) => isSameDay(t.date, _selected)).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            color: c.accent.withValues(alpha: 0.35),
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${greeting(now)}, ${user?.name ?? 'User'}',
                          style: AppText.mono(c.muted, size: 10)),
                      Text(
                        '${weekdayFull[now.weekday - 1]} ${now.day} ${monthsGenitive[now.month - 1]}',
                        style: AppText.mono(c.text, size: 13, weight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Сегодня',
                  onPressed: () => setState(() => _selected = dateOnly(now)),
                  icon: Icon(Icons.today, color: c.text),
                ),
              ],
            ),
          ),
          GestureDetector(
            onHorizontalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v.abs() > 200) _shiftWeek(v < 0 ? 1 : -1);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
              child: WeekStrip(
                weekStart: _weekStart,
                selected: _selected,
                onSelected: (d) => setState(() => _selected = d),
                hasTasks: (d) => tasks.any((t) => isSameDay(t.date, d)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_selected.day} ${monthsGenitive[_selected.month - 1]}',
                    style: AppText.section(c.text),
                  ),
                ),
                IconButton(onPressed: () => _shiftWeek(-1), icon: Icon(Icons.chevron_left, color: c.text)),
                IconButton(onPressed: () => _shiftWeek(1), icon: Icon(Icons.chevron_right, color: c.text)),
              ],
            ),
          ),
          Expanded(
            child: dayTasks.isEmpty
                ? Center(child: Text('На этот день задач нет', style: AppText.body(c.muted)))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    children: [for (final t in dayTasks) TaskTile(task: t)],
                  ),
          ),
        ],
      ),
    );
  }
}
