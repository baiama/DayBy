import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/primary_button.dart';
import 'task.dart';
import 'tasks_provider.dart';

/// Create or edit a task. Not in the Figma file yet; styled after it.
Future<void> showTaskEditor(
  BuildContext context, {
  Task? task,
  DateTime? date,
  String? listId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _TaskEditor(task: task, date: date, listId: listId),
  );
}

class _TaskEditor extends ConsumerStatefulWidget {
  const _TaskEditor({this.task, this.date, this.listId});

  final Task? task;
  final DateTime? date;
  final String? listId;

  @override
  ConsumerState<_TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends ConsumerState<_TaskEditor> {
  late final _title = TextEditingController(text: widget.task?.title);
  late DateTime _date = widget.task?.date ?? widget.date ?? DateTime.now();
  late String? _listId = widget.task?.listId ?? widget.listId;
  late bool _important = widget.task?.important ?? false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final notifier = ref.read(tasksProvider.notifier);
    final task = widget.task;
    if (task == null) {
      notifier.add(title: title, date: _date, listId: _listId, important: _important);
    } else {
      notifier.update(task.copyWith(
        title: title,
        date: dateOnly(_date),
        listId: _listId,
        important: _important,
      ));
    }
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ru'),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lists = ref.watch(listsProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.task == null ? 'Новая задача' : 'Задача', style: AppText.h3(c.text)),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            autofocus: widget.task == null,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _save(),
            style: AppText.body(c.text).copyWith(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Что нужно сделать?',
              filled: true,
              fillColor: c.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: c.stroke),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: c.stroke),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: Icon(Icons.today, size: 18, color: c.text),
                label: Text('${_date.day}.${_date.month.toString().padLeft(2, '0')}.${_date.year}'),
                onPressed: _pickDate,
              ),
              FilterChip(
                avatar: Icon(Icons.star_rounded, size: 18, color: c.accent),
                label: const Text('Важная'),
                selected: _important,
                selectedColor: c.accent.withValues(alpha: 0.25),
                onSelected: (v) => setState(() => _important = v),
              ),
              for (final l in lists)
                ChoiceChip(
                  label: Text('${l.emoji} ${l.name}'),
                  selected: _listId == l.id,
                  selectedColor: c.accent.withValues(alpha: 0.25),
                  onSelected: (v) => setState(() => _listId = v ? l.id : null),
                ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Сохранить', onPressed: _save),
        ],
      ),
    );
  }
}
