import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/segmented_pills.dart';
import '../../core/widgets/test_id.dart';
import '../tasks/task.dart';
import '../tasks/task_editor_sheet.dart';
import '../tasks/task_tile.dart';
import '../tasks/tasks_provider.dart';

/// «Мои списки». Not in the Figma file yet; uses the large rounded cards
/// from the «Home» draft frame.
class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final lists = ref.watch(listsProvider);
    final tasks = ref.watch(tasksProvider);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
        children: [
          Text('Мои списки', style: AppText.h1(c.text)),
          const SizedBox(height: 24),
          if (lists.isEmpty)
            EmptyState(
              testId: 'lists_empty',
              icon: Icons.folder_open_outlined,
              title: 'Списков пока нет',
              message: 'Разложите задачи по спискам: работа, дом, покупки.',
              actionLabel: 'Создать список',
              onAction: () => _createList(context, ref),
            ),
          for (final l in lists)
            Builder(
              builder: (context) {
                final items = tasks.where((t) => t.listId == l.id).toList();
                final done = items.where((t) => t.done).length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TestId(
                    'list_${l.id}',
                    child: Material(
                      color: c.accent.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => context.push('/lists/${l.id}'),
                        child: Container(
                          height: 120,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${l.emoji}  ${l.name}', style: AppText.h3(Colors.white)),
                              const Spacer(),
                              Text(
                                items.isEmpty ? 'Пока пусто' : '$done из ${items.length} выполнено',
                                style: AppText.body(Colors.white),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: items.isEmpty ? 0 : done / items.length,
                                  minHeight: 6,
                                  color: Colors.white,
                                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          if (lists.isNotEmpty)
            TestId(
              'lists_new',
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _createList(context, ref),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: c.accent, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: c.accent),
                      const SizedBox(width: 8),
                      Text('Новый список', style: AppText.button(c.accent)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _createList(BuildContext context, WidgetRef ref) async {
    final result = await showListEditor(context);
    if (result == null || !context.mounted) return;
    final id = ref.read(listsProvider.notifier).add(result.name, result.emoji);
    context.push('/lists/$id');
  }
}

enum _Filter {
  all('все'),
  active('активные'),
  done('готовые');

  const _Filter(this.label);
  final String label;
}

/// One list: accent header with progress, filter, tasks grouped by date.
class ListDetailScreen extends ConsumerStatefulWidget {
  const ListDetailScreen({super.key, required this.listId});

  final String listId;

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final list = ref.watch(listsProvider).where((l) => l.id == widget.listId).firstOrNull;
    if (list == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(leading: const TestId('list_back', child: BackButton())),
        body: const Center(
          child: EmptyState(
            testId: 'list_missing',
            icon: Icons.folder_off_outlined,
            title: 'Список не найден',
            message: 'Возможно, его удалили.',
          ),
        ),
      );
    }
    final all = ref.watch(tasksProvider).where((t) => t.listId == widget.listId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final done = all.where((t) => t.done).length;
    final shown = switch (_filter) {
      _Filter.all => all,
      _Filter.active => all.where((t) => !t.done).toList(),
      _Filter.done => all.where((t) => t.done).toList(),
    };
    final groups = _group(shown);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const TestId('list_back', child: BackButton()),
        actions: [
          PopupMenuButton<String>(
            key: const ValueKey('list_menu'),
            icon: Icon(Icons.more_vert, color: c.text),
            onSelected: (v) => switch (v) {
              'edit' => _edit(list),
              'clear' => _clearDone(),
              _ => _delete(list),
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Переименовать')),
              PopupMenuItem(value: 'clear', child: Text('Удалить выполненные')),
              PopupMenuItem(value: 'delete', child: Text('Удалить список')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          TestId(
            'list_header',
            keepChildren: true,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(list.emoji, style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        Text(list.name, style: AppText.h2(Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          all.isEmpty
                              ? 'Нет задач'
                              : '${all.length} ${plural(all.length, 'задача', 'задачи', 'задач')} · $done готово',
                          style: AppText.body(Colors.white),
                        ),
                      ],
                    ),
                  ),
                  ProgressRing(
                    value: all.isEmpty ? 0 : done / all.length,
                    color: Colors.white,
                    trackColor: Colors.white.withValues(alpha: 0.3),
                    size: 76,
                    thickness: 6,
                    child: Text(
                      '${all.isEmpty ? 0 : (done * 100 / all.length).round()}%',
                      style: AppText.h3(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (all.isNotEmpty) ...[
            const SizedBox(height: 16),
            SegmentedPills<_Filter>(
              values: _Filter.values,
              selected: _filter,
              labelOf: (f) => f.label,
              onChanged: (f) => setState(() => _filter = f),
              idOf: (f) => 'list_filter_${f.name}',
            ),
          ],
          const SizedBox(height: 8),
          if (all.isEmpty)
            EmptyState(
              testId: 'list_empty',
              icon: Icons.inbox_outlined,
              title: 'Список пуст',
              message: 'Добавьте первую задачу в «${list.name}».',
              actionLabel: 'Добавить задачу',
              onAction: () => showTaskEditor(context, listId: list.id),
            )
          else if (shown.isEmpty)
            EmptyState(
              testId: 'list_filter_empty',
              icon: _filter == _Filter.done
                  ? Icons.hourglass_empty_rounded
                  : Icons.celebration_outlined,
              title: _filter == _Filter.done ? 'Пока ничего не выполнено' : 'Всё сделано!',
              message: _filter == _Filter.done
                  ? 'Отмечайте задачи, и они появятся здесь.'
                  : 'В этом списке не осталось активных задач.',
              compact: true,
            )
          else
            for (final (title, items) in groups) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 4),
                child: Text(title, style: AppText.mono(c.muted, weight: FontWeight.w500)),
              ),
              for (final t in items) TaskTile(task: t),
            ],
        ],
      ),
    );
  }

  /// Overdue, today, tomorrow, later; done ones last.
  List<(String, List<Task>)> _group(List<Task> tasks) {
    final today = dateOnly(DateTime.now());
    final buckets = <String, List<Task>>{};
    for (final t in tasks) {
      final diff = t.date.difference(today).inDays;
      final key = t.done
          ? 'Выполнено'
          : diff < 0
          ? 'Просрочено'
          : diff == 0
          ? 'Сегодня'
          : diff == 1
          ? 'Завтра'
          : 'Позже';
      buckets.putIfAbsent(key, () => []).add(t);
    }
    const order = ['Просрочено', 'Сегодня', 'Завтра', 'Позже', 'Выполнено'];
    return [
      for (final k in order)
        if (buckets[k] case final items?) (k, items),
    ];
  }

  Future<void> _edit(TaskList list) async {
    final result = await showListEditor(context, initial: list);
    if (result == null) return;
    ref.read(listsProvider.notifier).rename(list.id, result.name, result.emoji);
  }

  void _clearDone() {
    final notifier = ref.read(tasksProvider.notifier);
    for (final t in ref.read(tasksProvider).where((t) => t.listId == widget.listId && t.done)) {
      notifier.remove(t.id);
    }
  }

  Future<void> _delete(TaskList list) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить «${list.name}»?'),
        content: const Text('Задачи останутся, но без списка.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TestId(
            'list_delete_confirm',
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Удалить'),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    ref.read(tasksProvider.notifier).detachList(list.id);
    context.pop();
    ref.read(listsProvider.notifier).remove(list.id);
  }
}

const listEmojis = ['📋', '💼', '🌸', '🛒', '🏠', '📚', '💪', '✈️', '🎯', '💡', '🎁', '🐾'];

/// Name + emoji sheet for creating or renaming a list.
Future<({String name, String emoji})?> showListEditor(BuildContext context, {TaskList? initial}) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ListEditor(initial: initial),
    );

class _ListEditor extends StatefulWidget {
  const _ListEditor({this.initial});

  final TaskList? initial;

  @override
  State<_ListEditor> createState() => _ListEditorState();
}

class _ListEditorState extends State<_ListEditor> {
  late final _name = TextEditingController(text: widget.initial?.name);
  late String _emoji = widget.initial?.emoji ?? listEmojis.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, (name: name, emoji: _emoji));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide(color: c.stroke),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.initial == null ? 'Новый список' : 'Список', style: AppText.h3(c.text)),
          const SizedBox(height: 16),
          TestId(
            'list_editor_name',
            child: TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _save(),
              style: AppText.body(c.text).copyWith(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Название',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_emoji, style: const TextStyle(fontSize: 20)),
                ),
                filled: true,
                fillColor: c.card,
                border: border,
                enabledBorder: border,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (i, e) in listEmojis.indexed)
                TestId(
                  'list_editor_emoji_$i',
                  child: GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: e == _emoji ? c.accent.withValues(alpha: 0.25) : c.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: e == _emoji ? c.accent : c.stroke, width: 1.5),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Сохранить', testId: 'list_editor_save', onPressed: _save),
        ],
      ),
    );
  }
}
