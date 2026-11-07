import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/test_id.dart';
import 'task.dart';
import 'tasks_provider.dart';

/// Task row with the 27 px rounded checkbox from the home screen.
class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task, this.showDate = false});

  final Task task;
  final bool showDate;

  /// Small captions under the title: list, date, subtasks, reminder, repeat.
  List<(IconData?, String)> _meta(TaskList? list) => [
    if (list != null) (null, '${list.emoji} ${list.name}'),
    if (showDate) (null, formatDay(task.date)),
    if (task.subtasks.isNotEmpty)
      (
        Icons.checklist_rounded,
        '${task.subtasks.where((s) => s.done).length}/${task.subtasks.length}',
      ),
    if (task.reminder != null) (Icons.notifications_none, formatTime(task.reminder!)),
    if (task.repeat != Repeat.none) (Icons.repeat_rounded, task.repeat.short),
    if (task.note.isNotEmpty) (Icons.sticky_note_2_outlined, ''),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final list = ref.watch(listsProvider).where((l) => l.id == task.listId).firstOrNull;
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete_outline, color: c.accent),
      ),
      onDismissed: (_) {
        final notifier = ref.read(tasksProvider.notifier);
        final index = ref.read(tasksProvider).indexWhere((t) => t.id == task.id);
        notifier.remove(task.id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Задача удалена'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Отменить',
                onPressed: () => notifier.restore(task, index),
              ),
            ),
          );
      },
      child: TestId(
        'task_${task.id}',
        keepChildren: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/task/${task.id}'),
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
                      if (_meta(list).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Wrap(
                            spacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              for (final (icon, text) in _meta(list))
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (icon != null) ...[
                                      Icon(icon, size: 13, color: c.muted),
                                      const SizedBox(width: 3),
                                    ],
                                    Text(
                                      text,
                                      style: AppText.caption(c.muted)
                                          .copyWith(fontSize: 12, height: 1.6),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (task.important)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(Icons.star_rounded, size: 18, color: c.accent),
                  ),
                TaskCheckBox(
                  testId: 'task_${task.id}_checkbox',
                  checked: task.done,
                  onTap: () => ref.read(tasksProvider.notifier).toggle(task.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded olive checkbox from the home screen (27 px by default).
class TaskCheckBox extends StatelessWidget {
  const TaskCheckBox({
    super.key,
    required this.testId,
    required this.checked,
    required this.onTap,
    this.size = 27,
  });

  final String testId;
  final bool checked;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      identifier: testId,
      container: true,
      checked: checked,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: checked ? c.text : Colors.transparent,
              border: Border.all(color: c.text, width: size > 24 ? 3 : 2.5),
              borderRadius: BorderRadius.circular(size * 0.22),
            ),
            child: checked
                ? Icon(Icons.check_rounded, size: size * 0.67, color: c.background)
                : null,
          ),
        ),
      ),
    );
  }
}
