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
import '../tasks/task.dart';
import '../tasks/task_tile.dart';
import '../tasks/tasks_provider.dart';

/// Search across all tasks by title, subtasks and note, with quick filters.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _query = TextEditingController();
  bool _important = false;
  bool _activeOnly = false;
  String? _listId;

  bool get _filtering => _important || _activeOnly || _listId != null;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _matches(Task t, String q) {
    if (_important && !t.important) return false;
    if (_activeOnly && t.done) return false;
    if (_listId != null && t.listId != _listId) return false;
    if (q.isEmpty) return true;
    return t.title.toLowerCase().contains(q) ||
        t.note.toLowerCase().contains(q) ||
        t.subtasks.any((s) => s.title.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lists = ref.watch(listsProvider);
    final q = _query.text.trim().toLowerCase();
    final idle = q.isEmpty && !_filtering;
    final results = idle
        ? const <Task>[]
        : (ref.watch(tasksProvider).where((t) => _matches(t, q)).toList()
            ..sort((a, b) => a.done == b.done ? a.date.compareTo(b.date) : (a.done ? 1 : -1)));

    Widget chip(
      String id,
      String label,
      bool selected,
      ValueChanged<bool> onSelected, {
      IconData? icon,
    }) => TestId(
      id,
      child: FilterChip(
        avatar: icon == null ? null : Icon(icon, size: 18, color: c.accent),
        label: Text(label),
        labelStyle: AppText.body(c.text).copyWith(fontWeight: FontWeight.w600),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        selected: selected,
        showCheckmark: false,
        selectedColor: c.accent.withValues(alpha: 0.3),
        backgroundColor: c.card,
        side: BorderSide(color: selected ? c.accent : c.stroke),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        onSelected: onSelected,
      ),
    );

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
              child: Row(
                children: [
                  TestId(
                    'search_back',
                    child: IconButton(
                      tooltip: 'Назад',
                      onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                      icon: Icon(Icons.arrow_back, color: c.text),
                    ),
                  ),
                  Expanded(
                    child: TestId(
                      'search_input',
                      child: TextField(
                        controller: _query,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        style: AppText.body(c.text).copyWith(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Поиск задач',
                          prefixIcon: Icon(Icons.search, color: c.muted),
                          suffixIcon: _query.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Очистить',
                                  onPressed: () => setState(_query.clear),
                                  icon: Icon(Icons.close, color: c.muted),
                                ),
                          filled: true,
                          fillColor: c.card,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  chip(
                    'search_filter_important',
                    'Важные',
                    _important,
                    (v) => setState(() => _important = v),
                    icon: Icons.star_rounded,
                  ),
                  const SizedBox(width: 8),
                  chip(
                    'search_filter_active',
                    'Невыполненные',
                    _activeOnly,
                    (v) => setState(() => _activeOnly = v),
                  ),
                  for (final l in lists) ...[
                    const SizedBox(width: 8),
                    chip(
                      'search_filter_list_${l.id}',
                      '${l.emoji} ${l.name}',
                      _listId == l.id,
                      (v) => setState(() => _listId = v ? l.id : null),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: idle
                  ? const SingleChildScrollView(
                      child: EmptyState(
                        testId: 'search_idle',
                        icon: Icons.manage_search_rounded,
                        title: 'Что ищем?',
                        message:
                            'Ищем по названию, подзадачам и заметкам. Или выберите фильтр выше.',
                      ),
                    )
                  : results.isEmpty
                  ? SingleChildScrollView(
                      child: EmptyState(
                        testId: 'search_empty',
                        icon: Icons.search_off_rounded,
                        title: 'Ничего не нашлось',
                        message: q.isEmpty
                            ? 'Попробуйте убрать часть фильтров.'
                            : 'По запросу «${_query.text.trim()}» задач нет.',
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      children: [
                        TestId(
                          'search_count',
                          child: Text(
                            '${results.length} ${plural(results.length, 'задача', 'задачи', 'задач')}',
                            style: AppText.mono(c.muted, weight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [for (final t in results) TaskTile(task: t, showDate: true)],
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
}
