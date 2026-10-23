import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import 'task.dart';
import 'task_editor_sheet.dart';
import 'tasks_provider.dart';

/// Task row with the 27 px rounded checkbox from the home screen.
class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task, this.showDate = false});

  final Task task;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final list = ref
        .watch(listsProvider)
        .where((l) => l.id == task.listId)
        .firstOrNull;
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete_outline, color: c.accent),
      ),
      onDismissed: (_) => ref.read(tasksProvider.notifier).remove(task.id),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showTaskEditor(context, task: task),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppText.body(c.text).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.done ? TextDecoration.lineThrough : null,
                        color: task.done ? c.muted : c.text,
                      ),
                    ),
                    if (list != null || showDate)
                      Text(
                        [
                          if (list != null) '${list.emoji} ${list.name}',
                          if (showDate) '${task.date.day}.${task.date.month.toString().padLeft(2, '0')}',
                        ].join('  ·  '),
                        style: AppText.caption(c.muted).copyWith(fontSize: 12, height: 1.6),
                      ),
                  ],
                ),
              ),
              if (task.important)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.star_rounded, size: 18, color: c.accent),
                ),
              _CheckBox(
                checked: task.done,
                onTap: () => ref.read(tasksProvider.notifier).toggle(task.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      checked: checked,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: checked ? c.text : Colors.transparent,
              border: Border.all(color: c.text, width: 3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: checked
                ? Icon(Icons.check_rounded, size: 18, color: c.background)
                : null,
          ),
        ),
      ),
    );
  }
}
