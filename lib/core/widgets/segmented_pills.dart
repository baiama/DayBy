import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Three-way pill switch from the profile «Оформление» card.
class SegmentedPills<T> extends StatelessWidget {
  const SegmentedPills({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 30,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          for (final v in values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: v == selected ? c.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    child: Text(
                      labelOf(v),
                      style: AppText.setting(
                        v == selected ? Colors.white : c.text,
                      ).copyWith(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
