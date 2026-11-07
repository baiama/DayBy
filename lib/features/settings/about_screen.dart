import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/dayby_logo.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/test_id.dart';

/// «О приложении»: logo, version, short pitch and links.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const version = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    void soon() =>
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Скоро будет доступно')));
    return GradientScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(17, 0, 17, 32),
          children: [
            const ScreenHeader(title: 'О приложении', backId: 'about_back', fallback: '/profile'),
            const SizedBox(height: 24),
            const Center(child: DayByLogo(width: 120)),
            const SizedBox(height: 8),
            Text('DayBy', textAlign: TextAlign.center, style: AppText.logo(c.text)),
            Text('Планировщик дел', textAlign: TextAlign.center, style: AppText.setting(c.text)),
            const SizedBox(height: 6),
            TestId(
              'about_version',
              child: Text(
                'Версия $version',
                textAlign: TextAlign.center,
                style: AppText.mono(c.muted),
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Text(
                'DayBy помогает планировать день без лишнего шума: '
                'важные задачи на виду, списки под рукой, а статистика '
                'показывает, как вы продвигаетесь неделя за неделей.',
                style: AppText.body(c.text).copyWith(fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (final (id, icon, title) in const [
                    ('about_rate', Icons.star_outline_rounded, 'Оценить приложение'),
                    ('about_feedback', Icons.mail_outline, 'Написать нам'),
                    ('about_privacy', Icons.shield_outlined, 'Политика конфиденциальности'),
                    ('about_terms', Icons.description_outlined, 'Условия использования'),
                  ])
                    TestId(
                      id,
                      child: ListTile(
                        onTap: soon,
                        leading: SectionIcon(icon),
                        title: Text(title, style: AppText.setting(c.text).copyWith(fontSize: 15)),
                        trailing: Icon(Icons.chevron_right, color: c.muted),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '© ${DateTime.now().year} chotatam company',
              textAlign: TextAlign.center,
              style: AppText.caption(c.muted).copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
