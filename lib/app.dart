import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/appearance.dart';

class DayByApp extends ConsumerWidget {
  const DayByApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final look = ref.watch(appearanceProvider);
    return MaterialApp.router(
      title: 'DayBy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(look.accent),
      darkTheme: AppTheme.dark(look.accent),
      themeMode: look.themeMode,
      routerConfig: ref.watch(routerProvider),
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(look.textSize.scale),
        ),
        child: child!,
      ),
    );
  }
}
