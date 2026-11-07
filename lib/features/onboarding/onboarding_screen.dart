import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/test_id.dart';
import '../settings/settings_provider.dart';

/// Three intro slides shown once, between splash and login.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;

  static const _slides = [
    (
      'Планируйте день',
      'Записывайте дела, отмечайте важные звёздочкой и закрывайте одно за другим.',
      _TasksArt(),
    ),
    (
      'Всё по полочкам',
      'Работа, дом, покупки: раскладывайте задачи по спискам и добавляйте подзадачи.',
      _ListsArt(),
    ),
    (
      'Видно прогресс',
      'Напоминания не дадут забыть, а статистика покажет, как проходит неделя.',
      _ProgressArt(),
    ),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _finish() {
    ref.read(onboardingDoneProvider.notifier).complete();
    context.go('/login');
  }

  void _next() {
    if (_index == _slides.length - 1) return _finish();
    _pages.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final last = _index == _slides.length - 1;
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 12, 0),
                child: AnimatedOpacity(
                  opacity: last ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TestId(
                    'onboarding_skip',
                    child: TextButton(
                      onPressed: last ? null : _finish,
                      child: Text('Пропустить', style: AppText.mono(c.text, size: 14)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                key: const ValueKey('onboarding_pages'),
                controller: _pages,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  for (final (i, (title, text, art)) in _slides.indexed)
                    TestId(
                      'onboarding_page_$i',
                      keepChildren: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            const Spacer(),
                            SizedBox(height: 280, child: Center(child: art)),
                            const Spacer(),
                            Text(title, textAlign: TextAlign.center, style: AppText.h1(c.text)),
                            const SizedBox(height: 16),
                            Text(
                              text,
                              textAlign: TextAlign.center,
                              style: AppText.body(c.text).copyWith(fontSize: 16, height: 1.45),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index ? c.accent : c.accent.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(39, 24, 39, 24),
              child: PrimaryButton(
                label: last ? 'Начать' : 'Далее',
                testId: 'onboarding_next',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fake task rows tilted like a stack of cards.
class _TasksArt extends StatelessWidget {
  const _TasksArt();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget row(String title, bool done, bool star) => Container(
      width: 250,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: c.primaryShadow.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppText.body(done ? c.muted : c.text).copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (star) Icon(Icons.star_rounded, color: c.accent, size: 18),
          const SizedBox(width: 8),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: done ? c.text : Colors.transparent,
              border: Border.all(color: c.text, width: 2.5),
              borderRadius: BorderRadius.circular(5),
            ),
            child: done ? Icon(Icons.check_rounded, size: 15, color: c.background) : null,
          ),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(angle: -0.05, child: row('Утренняя пробежка', true, false)),
        row('Сдать отчёт', false, true),
        Transform.rotate(angle: 0.04, child: row('Купить цветы', false, false)),
      ],
    );
  }
}

class _ListsArt extends StatelessWidget {
  const _ListsArt();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget card(String emoji, String name, double value, double alpha, double dx) =>
        Transform.translate(
          offset: Offset(dx, 0),
          child: Container(
            width: 230,
            height: 72,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: alpha),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$emoji  $name', style: AppText.h3(Colors.white).copyWith(fontSize: 17)),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 5,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        card('💼', 'Работа', 0.6, 0.95, -16),
        card('🌸', 'Личное', 0.35, 0.75, 16),
        card('🛒', 'Покупки', 0.8, 0.55, -8),
      ],
    );
  }
}

class _ProgressArt extends StatelessWidget {
  const _ProgressArt();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const bars = [0.4, 0.7, 0.55, 0.9, 0.65, 0.3, 0.5];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: ProgressRing(
                value: 0.75,
                color: c.text,
                trackColor: c.accent,
                size: 120,
                child: Text('75%', style: AppText.logo(c.text).copyWith(fontSize: 28)),
              ),
            ),
            Positioned(
              right: -28,
              top: -12,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.card,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.primaryShadow.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.notifications_active_outlined, color: c.accent, size: 26),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 60,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, v) in bars.indexed)
                Container(
                  width: 18,
                  height: 60 * v,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: i == 3 ? c.accent : c.text.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
