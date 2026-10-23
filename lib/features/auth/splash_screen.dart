import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/dayby_logo.dart';
import '../../core/widgets/gradient_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final light = Theme.of(context).brightness == Brightness.light;
    return GradientScaffold(
      gradient: light
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.27, 2.6],
              colors: [Color(0xFFFFE9DA), Color(0xFFDC8281)],
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 5),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (_, s, child) => Transform.scale(scale: s, child: child),
              child: const DayByLogo(),
            ),
            Text('DayBy', style: AppText.logo(c.text)),
            Text(
              'Планировщик дел',
              style: AppText.setting(c.text).copyWith(letterSpacing: 0.8),
            ),
            const Spacer(flex: 7),
            Text(
              'chotatam company',
              style: AppText.caption(c.text)
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
