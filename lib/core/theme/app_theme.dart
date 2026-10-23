import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light(Color accent) =>
      _build(Brightness.light, DayByColors.light(accent));

  static ThemeData dark(Color accent) =>
      _build(Brightness.dark, DayByColors.dark(accent));

  static ThemeData _build(Brightness brightness, DayByColors c) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.accent,
      brightness: brightness,
    ).copyWith(
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.accent,
      surface: c.elevation,
      onSurface: c.text,
      outline: c.stroke,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      extensions: [c],
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: GoogleFonts.figtree().fontFamily,
        bodyColor: c.text,
        displayColor: c.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.text,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.primary,
        contentTextStyle: TextStyle(color: c.onPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.elevation,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(backgroundColor: c.elevation),
    );
  }
}
