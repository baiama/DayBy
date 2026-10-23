import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/appearance.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/segmented_pills.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final user = ref.watch(authProvider);
    final look = ref.watch(appearanceProvider);
    final appearance = ref.read(appearanceProvider.notifier);

    // Material (not a coloured Container) so ListTile ripples stay visible.
    Widget card({required Widget child, EdgeInsets? padding}) => Material(
          color: c.card,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: SizedBox(width: double.infinity, child: child),
          ),
        );

    Widget sectionIcon(IconData icon) => Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: c.accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 18, color: c.accent),
        );

    return GradientScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(17, 0, 17, 32),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                  icon: Icon(Icons.arrow_back, color: c.text),
                ),
                Text('DayBy', style: AppText.logo(c.text)),
              ],
            ),
            const SizedBox(height: 24),
            card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: c.accent.withValues(alpha: 0.8),
                            child: Text(
                              (user?.name.isNotEmpty ?? false)
                                  ? user!.name[0].toUpperCase()
                                  : 'U',
                              style: AppText.h2(Colors.white),
                            ),
                          ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: CircleAvatar(
                              radius: 13,
                              backgroundColor: AppPalette.beige,
                              child: Icon(Icons.photo_camera_outlined, size: 14, color: c.accent),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? 'User Name', style: AppText.setting(c.text)),
                            Text(
                              user?.email ?? 'useremail@gmail.com',
                              overflow: TextOverflow.ellipsis,
                              style: AppText.setting(c.text),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _editName(context, ref, user?.name ?? ''),
                    child: Text('изменить', style: AppText.setting(c.accent)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            card(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _MenuRow(icon: Icons.notifications_none, label: 'Уведомления', onTap: () {}),
                  _MenuRow(icon: Icons.language, label: 'Язык', trailing: 'Русский', onTap: () {}),
                  _MenuRow(icon: Icons.info_outline, label: 'О приложении', onTap: () {}),
                  _MenuRow(
                    icon: Icons.logout,
                    label: 'Выйти',
                    onTap: () {
                      ref.read(authProvider.notifier).signOut();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 3, bottom: 8),
              child: Text('Оформление', style: AppText.setting(c.text)),
            ),
            card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Тема', style: AppText.setting(c.text)),
                  const SizedBox(height: 10),
                  SegmentedPills<ThemeMode>(
                    values: const [ThemeMode.system, ThemeMode.light, ThemeMode.dark],
                    selected: look.themeMode,
                    labelOf: (m) => switch (m) {
                      ThemeMode.system => 'системная',
                      ThemeMode.light => 'светлая',
                      ThemeMode.dark => 'тёмная',
                    },
                    onChanged: appearance.setThemeMode,
                  ),
                  Divider(height: 32, color: c.stroke),
                  Row(children: [
                    sectionIcon(Icons.palette_outlined),
                    const SizedBox(width: 6),
                    Text('Акцентные цвета', style: AppText.setting(c.text)),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final color in AppPalette.accentOptions)
                        GestureDetector(
                          onTap: () => appearance.setAccent(color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: look.accent.toARGB32() == color.toARGB32()
                                    ? c.text
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Divider(height: 32, color: c.stroke),
                  Row(children: [
                    sectionIcon(Icons.text_fields),
                    const SizedBox(width: 6),
                    Text('Размер текста', style: AppText.setting(c.text)),
                  ]),
                  const SizedBox(height: 10),
                  SegmentedPills<TextSize>(
                    values: TextSize.values,
                    selected: look.textSize,
                    labelOf: (s) => s.label,
                    onChanged: appearance.setTextSize,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(BuildContext context, WidgetRef ref, String current) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Имя'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.isNotEmpty) {
      ref.read(authProvider.notifier).updateName(name);
    }
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, required this.onTap, this.trailing});

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: c.text),
      title: Text(label, style: AppText.setting(c.text)),
      trailing: trailing != null
          ? Text(trailing!, style: AppText.setting(c.muted).copyWith(fontSize: 14))
          : Icon(Icons.chevron_right, color: c.muted),
    );
  }
}
