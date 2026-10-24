import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/test_id.dart';
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
                                '$done из ${items.length} выполнено',
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
        ],
      ),
    );
  }
}

class ListDetailScreen extends ConsumerWidget {
  const ListDetailScreen({super.key, required this.listId});

  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final list = ref.watch(listsProvider).firstWhere((l) => l.id == listId);
    final tasks = ref.watch(tasksProvider).where((t) => t.listId == listId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return Scaffold(
      appBar: AppBar(
        leading: const TestId('list_back', child: BackButton()),
        title: Text('${list.emoji} ${list.name}', style: AppText.h3(c.text)),
      ),
      body: tasks.isEmpty
          ? Center(
              child: TestId('list_empty', child: Text('Список пуст', style: AppText.body(c.muted))),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [for (final t in tasks) TaskTile(task: t, showDate: true)],
            ),
    );
  }
}
