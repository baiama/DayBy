import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/test_id.dart';
import 'task.dart';
import 'task_editor_sheet.dart';
import 'task_tile.dart';
import 'tasks_provider.dart';

/// Full task card: status, date and list, subtasks, note, repeat and
/// reminder. Opened by tapping a task row.
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final task = ref.watch(
      tasksProvider.select((ts) => ts.where((t) => t.id == taskId).firstOrNull),
    );
    if (task == null) {
      return GradientScaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ScreenHeader(title: '', backId: 'task_detail_back'),
              ),
              Expanded(
                child: Center(
                  child: EmptyState(
                    testId: 'task_detail_missing',
                    icon: Icons.search_off_rounded,
                    title: 'Задача не найдена',
                    message: 'Возможно, её уже удалили.',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final notifier = ref.read(tasksProvider.notifier);
    final list = ref.watch(listsProvider).where((l) => l.id == task.listId).firstOrNull;
    final doneSubs = task.subtasks.where((s) => s.done).length;

    return GradientScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(17, 0, 17, 32),
          children: [
            ScreenHeader(
              title: '',
              backId: 'task_detail_back',
              actions: [
                TestId(
                  'task_detail_important',
                  child: IconButton(
                    tooltip: 'Важная',
                    onPressed: () => notifier.update(task.copyWith(important: !task.important)),
                    icon: Icon(
                      task.important ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: c.accent,
                      size: 28,
                    ),
                  ),
                ),
                TestId(
                  'task_detail_edit',
                  child: IconButton(
                    tooltip: 'Изменить',
                    onPressed: () => showTaskEditor(context, task: task),
                    icon: Icon(Icons.edit_outlined, color: c.text),
                  ),
                ),
                TestId(
                  'task_detail_delete',
                  child: IconButton(
                    tooltip: 'Удалить',
                    onPressed: () => _delete(context, ref, task),
                    icon: Icon(Icons.delete_outline, color: c.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Title and status
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TestId(
                          'task_detail_title',
                          child: Text(
                            task.title,
                            style: AppText.h2(task.done ? c.muted : c.text).copyWith(
                              height: 1.2,
                              decoration: task.done ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          task.done ? 'Выполнено' : 'В процессе',
                          style: AppText.mono(
                            task.done ? c.accent : c.muted,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TaskCheckBox(
                    testId: 'task_detail_checkbox',
                    checked: task.done,
                    onTap: () => notifier.toggle(task.id),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // When and where
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _InfoRow(
                    testId: 'task_detail_date',
                    icon: Icons.today_outlined,
                    label: 'Дата',
                    value: formatDay(task.date),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: task.date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        locale: const Locale('ru'),
                      );
                      if (picked != null) notifier.update(task.copyWith(date: dateOnly(picked)));
                    },
                  ),
                  _InfoRow(
                    testId: 'task_detail_list',
                    icon: Icons.format_list_bulleted,
                    label: 'Список',
                    value: list == null ? 'Без списка' : '${list.emoji} ${list.name}',
                    onTap: () => _pickList(context, ref, task),
                  ),
                  _InfoRow(
                    testId: 'task_detail_reminder',
                    icon: Icons.notifications_none,
                    label: 'Напоминание',
                    value: task.reminder == null ? 'Нет' : formatTime(task.reminder!),
                    onTap: () => _pickReminder(context, ref, task),
                    onClear: task.reminder == null
                        ? null
                        : () => notifier.update(task.copyWith(reminder: null)),
                  ),
                  _InfoRow(
                    testId: 'task_detail_repeat',
                    icon: Icons.repeat_rounded,
                    label: 'Повтор',
                    value: task.repeat == Repeat.none ? 'Нет' : task.repeat.short,
                    onTap: () => _pickRepeat(context, ref, task),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    icon: Icons.checklist_rounded,
                    title: 'Подзадачи',
                    trailing: task.subtasks.isEmpty
                        ? null
                        : Text(
                            '$doneSubs/${task.subtasks.length}',
                            style: AppText.mono(c.muted, weight: FontWeight.w500),
                          ),
                  ),
                  if (task.subtasks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: doneSubs / task.subtasks.length,
                        minHeight: 6,
                        color: c.accent,
                        backgroundColor: c.accent.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  for (final s in task.subtasks)
                    _SubtaskRow(
                      key: ValueKey(s.id),
                      subtask: s,
                      onToggle: () => notifier.toggleSubtask(task.id, s.id),
                      onRemove: () => notifier.removeSubtask(task.id, s.id),
                    ),
                  _AddSubtaskField(onAdd: (title) => notifier.addSubtask(task.id, title)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(icon: Icons.sticky_note_2_outlined, title: 'Заметка'),
                  const SizedBox(height: 8),
                  _NoteField(
                    key: ValueKey('note_${task.id}'),
                    initial: task.note,
                    onChanged: (v) => notifier.update(
                      ref.read(tasksProvider.notifier).byId(task.id)!.copyWith(note: v),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Task task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить задачу?'),
        content: Text('«${task.title}» будет удалена без возможности восстановления.'),
        actions: [
          TestId(
            'task_delete_cancel',
            child: TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
          ),
          TestId(
            'task_delete_confirm',
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Удалить'),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    ref.read(tasksProvider.notifier).remove(task.id);
    context.canPop() ? context.pop() : context.go('/home');
  }

  Future<void> _pickList(BuildContext context, WidgetRef ref, Task task) async {
    final lists = ref.read(listsProvider);
    final c = context.colors;
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final l in [null, ...lists])
              TestId(
                'task_detail_list_${l?.id ?? 'none'}',
                child: ListTile(
                  leading: Text(l?.emoji ?? '—', style: const TextStyle(fontSize: 20)),
                  title: Text(l?.name ?? 'Без списка', style: AppText.setting(c.text)),
                  trailing: task.listId == l?.id ? Icon(Icons.check, color: c.accent) : null,
                  onTap: () => Navigator.pop(context, l?.id ?? ''),
                ),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    final notifier = ref.read(tasksProvider.notifier);
    notifier.update(notifier.byId(task.id)!.copyWith(listId: picked.isEmpty ? null : picked));
  }

  Future<void> _pickReminder(BuildContext context, WidgetRef ref, Task task) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: task.reminder ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    final notifier = ref.read(tasksProvider.notifier);
    notifier.update(notifier.byId(task.id)!.copyWith(reminder: picked));
  }

  Future<void> _pickRepeat(BuildContext context, WidgetRef ref, Task task) async {
    final c = context.colors;
    final picked = await showModalBottomSheet<Repeat>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in Repeat.values)
              TestId(
                'task_detail_repeat_${r.name}',
                child: ListTile(
                  title: Text(r.label, style: AppText.setting(c.text)),
                  trailing: task.repeat == r ? Icon(Icons.check, color: c.accent) : null,
                  onTap: () => Navigator.pop(context, r),
                ),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    final notifier = ref.read(tasksProvider.notifier);
    notifier.update(notifier.byId(task.id)!.copyWith(repeat: picked));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.testId,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String testId;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TestId(
      testId,
      child: ListTile(
        onTap: onTap,
        leading: SectionIcon(icon),
        title: Text(label, style: AppText.setting(c.text)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: AppText.setting(c.muted).copyWith(fontSize: 14)),
            if (onClear != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Убрать',
                onPressed: onClear,
                icon: Icon(Icons.close, size: 18, color: c.muted),
              )
            else
              Icon(Icons.chevron_right, color: c.muted),
          ],
        ),
      ),
    );
  }
}

class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({
    super.key,
    required this.subtask,
    required this.onToggle,
    required this.onRemove,
  });

  final Subtask subtask;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TestId(
      'subtask_${subtask.id}',
      keepChildren: true,
      child: Row(
        children: [
          TaskCheckBox(
            testId: 'subtask_${subtask.id}_checkbox',
            checked: subtask.done,
            size: 22,
            onTap: onToggle,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              subtask.title,
              style: AppText.body(subtask.done ? c.muted : c.text).copyWith(
                fontSize: 15,
                decoration: subtask.done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Удалить',
            onPressed: onRemove,
            icon: Icon(Icons.close, size: 18, color: c.muted),
          ),
        ],
      ),
    );
  }
}

class _AddSubtaskField extends StatefulWidget {
  const _AddSubtaskField({required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  State<_AddSubtaskField> createState() => _AddSubtaskFieldState();
}

class _AddSubtaskFieldState extends State<_AddSubtaskField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(Icons.add, color: c.accent, size: 22),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: TestId(
            'subtask_add',
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: AppText.body(c.text).copyWith(fontSize: 15),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Добавить подзадачу',
                hintStyle: AppText.body(c.muted).copyWith(fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteField extends StatefulWidget {
  const _NoteField({super.key, required this.initial, required this.onChanged});

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<_NoteField> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TestId(
      'task_detail_note',
      child: TextField(
        controller: _controller,
        minLines: 3,
        maxLines: 8,
        textCapitalization: TextCapitalization.sentences,
        onChanged: widget.onChanged,
        style: AppText.body(c.text).copyWith(fontSize: 15, height: 1.4),
        decoration: InputDecoration(
          hintText: 'Детали, ссылки, мысли…',
          hintStyle: AppText.body(c.muted).copyWith(fontSize: 15),
          filled: true,
          fillColor: c.elevation,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.stroke),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.stroke),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}
