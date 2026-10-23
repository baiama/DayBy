import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/tasks/task_editor_sheet.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'gradient_scaffold.dart';

/// Tab shell from the home frame: olive divider line, four tabs, «+» FAB.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    (Icons.home_outlined, Icons.home, 'Главная'),
    (Icons.format_list_bulleted, Icons.format_list_bulleted, 'Мои списки'),
    (Icons.bar_chart_outlined, Icons.bar_chart, 'Статистика'),
    (Icons.today_outlined, Icons.today, 'Календарь'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GradientScaffold(
      gradient: Theme.of(context).brightness == Brightness.light
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.3, 1.6],
              colors: [Color(0xFFFFE9DB), Color(0xFFECB5B2)],
            )
          : null,
      body: shell,
      floatingActionButton: shell.currentIndex == 2
          ? null
          : _AddButton(onPressed: () => showTaskEditor(context)),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.only(top: 6, bottom: 4),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.text, width: 2)),
          ),
          child: Row(
            children: [
              for (final (i, (icon, activeIcon, label)) in _tabs.indexed)
                Expanded(
                  child: InkResponse(
                    onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            i == shell.currentIndex ? activeIcon : icon,
                            size: 28,
                            color: i == shell.currentIndex ? c.accent : c.text,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            style: AppText.mono(
                              i == shell.currentIndex ? c.accent : c.text,
                              size: 10,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Новая задача',
      button: true,
      child: Container(
        width: 65,
        height: 59,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(color: c.primaryShadow, offset: const Offset(0, 4), blurRadius: 0.8),
          ],
        ),
        child: Material(
          color: c.primary,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: onPressed,
            child: Icon(Icons.add, size: 36, color: c.background),
          ),
        ),
      ),
    );
  }
}
