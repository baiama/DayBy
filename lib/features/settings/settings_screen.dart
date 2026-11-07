import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/segmented_pills.dart';
import '../../core/widgets/test_id.dart';
import '../tasks/tasks_provider.dart';
import 'settings_provider.dart';

/// «Настройки»: notifications, task defaults, language and data.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    Widget label(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(3, 24, 0, 8),
      child: Text(text, style: AppText.setting(c.text)),
    );

    return GradientScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(17, 0, 17, 32),
          children: [
            const ScreenHeader(title: 'Настройки', backId: 'settings_back', fallback: '/profile'),
            label('Уведомления'),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  SwitchRow(
                    testId: 'settings_reminders',
                    icon: Icons.notifications_none,
                    title: 'Напоминания о задачах',
                    subtitle: 'В указанное в задаче время',
                    value: s.reminders,
                    onChanged: n.setReminders,
                  ),
                  SwitchRow(
                    testId: 'settings_sound',
                    icon: Icons.volume_up_outlined,
                    title: 'Звук',
                    value: s.sound,
                    onChanged: s.reminders ? n.setSound : null,
                  ),
                  SwitchRow(
                    testId: 'settings_digest',
                    icon: Icons.wb_sunny_outlined,
                    title: 'Утренняя сводка',
                    subtitle: 'Что запланировано на день',
                    value: s.dailyDigest,
                    onChanged: n.setDailyDigest,
                  ),
                  ValueRow(
                    testId: 'settings_digest_time',
                    icon: Icons.schedule,
                    title: 'Время сводки',
                    value: formatTime(s.digestTime),
                    enabled: s.dailyDigest,
                    onTap: () async {
                      final t = await pickTime(context, s.digestTime);
                      if (t != null) n.setDigestTime(t);
                    },
                  ),
                ],
              ),
            ),
            label('Задачи'),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(icon: Icons.calendar_view_week, title: 'Начало недели'),
                        const SizedBox(height: 10),
                        SegmentedPills<bool>(
                          values: const [true, false],
                          selected: s.weekStartsMonday,
                          labelOf: (v) => v ? 'понедельник' : 'воскресенье',
                          onChanged: n.setWeekStartsMonday,
                          idOf: (v) => v ? 'settings_week_monday' : 'settings_week_sunday',
                        ),
                      ],
                    ),
                  ),
                  SwitchRow(
                    testId: 'settings_show_completed',
                    icon: Icons.task_alt,
                    title: 'Выполненные на главной',
                    value: s.showCompleted,
                    onChanged: n.setShowCompleted,
                  ),
                  ValueRow(
                    testId: 'settings_default_reminder',
                    icon: Icons.alarm,
                    title: 'Напоминание по умолчанию',
                    value: formatTime(s.defaultReminder),
                    onTap: () async {
                      final t = await pickTime(context, s.defaultReminder);
                      if (t != null) n.setDefaultReminder(t);
                    },
                  ),
                ],
              ),
            ),
            label('Общие'),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ValueRow(
                    testId: 'settings_language',
                    icon: Icons.language,
                    title: 'Язык',
                    value: s.language == 'ru' ? 'Русский' : 'English',
                    onTap: () => _pickLanguage(context, ref),
                  ),
                  ValueRow(
                    testId: 'settings_clear_done',
                    icon: Icons.cleaning_services_outlined,
                    title: 'Удалить выполненные',
                    onTap: () => _clearDone(context, ref),
                  ),
                  ValueRow(
                    testId: 'settings_about',
                    icon: Icons.info_outline,
                    title: 'О приложении',
                    onTap: () => context.push('/about'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final c = context.colors;
    final current = ref.read(settingsProvider).language;
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (code, name) in const [('ru', 'Русский'), ('en', 'English')])
              TestId(
                'settings_language_$code',
                child: ListTile(
                  title: Text(name, style: AppText.setting(c.text)),
                  trailing: code == current ? Icon(Icons.check, color: c.accent) : null,
                  onTap: () => Navigator.pop(context, code),
                ),
              ),
          ],
        ),
      ),
    );
    if (picked != null) ref.read(settingsProvider.notifier).setLanguage(picked);
  }

  Future<void> _clearDone(BuildContext context, WidgetRef ref) async {
    final count = ref.read(tasksProvider).where((t) => t.done).length;
    final messenger = ScaffoldMessenger.of(context);
    if (count == 0) {
      messenger.showSnackBar(const SnackBar(content: Text('Выполненных задач нет')));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить выполненные?'),
        content: Text('Будет удалено $count ${plural(count, 'задача', 'задачи', 'задач')}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TestId(
            'settings_clear_confirm',
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Удалить'),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    ref.read(tasksProvider.notifier).removeDone();
    messenger.showSnackBar(const SnackBar(content: Text('Готово')));
  }
}

Future<TimeOfDay?> pickTime(BuildContext context, TimeOfDay initial) => showTimePicker(
  context: context,
  initialTime: initial,
  builder: (context, child) =>
      MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
);

class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.testId,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String testId;
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TestId(
      testId,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: SectionIcon(icon),
        activeThumbColor: Colors.white,
        activeTrackColor: c.accent,
        inactiveTrackColor: c.accent.withValues(alpha: 0.15),
        trackOutlineColor: WidgetStatePropertyAll(c.accent.withValues(alpha: 0.4)),
        title: Text(title, style: AppText.setting(c.text).copyWith(fontSize: 15)),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: AppText.body(c.muted).copyWith(fontSize: 12)),
      ),
    );
  }
}

class ValueRow extends StatelessWidget {
  const ValueRow({
    super.key,
    required this.testId,
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.enabled = true,
  });

  final String testId;
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TestId(
      testId,
      child: ListTile(
        enabled: enabled,
        onTap: onTap,
        leading: Opacity(opacity: enabled ? 1 : 0.4, child: SectionIcon(icon)),
        title: Text(
          title,
          style: AppText.setting(enabled ? c.text : c.muted).copyWith(fontSize: 15),
        ),
        trailing: value == null
            ? Icon(Icons.chevron_right, color: c.muted)
            : Text(value!, style: AppText.setting(c.muted).copyWith(fontSize: 14)),
      ),
    );
  }
}
