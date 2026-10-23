import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

const weekdayShort = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];

/// Seven 50×90 day pills from the «Home» draft frame.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.weekStart,
    required this.selected,
    required this.onSelected,
    required this.hasTasks,
  });

  final DateTime weekStart;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final bool Function(DateTime) hasTasks;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: _DayPill(
                date: weekStart.add(Duration(days: i)),
                label: weekdayShort[i],
                selected: DateUtils.isSameDay(weekStart.add(Duration(days: i)), selected),
                dot: hasTasks(weekStart.add(Duration(days: i))),
                colors: c,
                onTap: () => onSelected(weekStart.add(Duration(days: i))),
              ),
            ),
          ),
      ],
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.date,
    required this.label,
    required this.selected,
    required this.dot,
    required this.colors,
    required this.onTap,
  });

  final DateTime date;
  final String label;
  final bool selected;
  final bool dot;
  final DayByColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : colors.text;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 90,
        decoration: BoxDecoration(
          color: selected ? colors.accent : colors.accent.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(label,
                  style: AppText.mono(fg, size: 22, weight: FontWeight.w500)),
            ),
            Text('${date.day}', style: AppText.mono(fg, size: 13)),
            SizedBox(
              height: 12,
              child: dot ? Text('•••', style: AppText.mono(fg, size: 8)) : null,
            ),
          ],
        ),
      ),
    );
  }
}
