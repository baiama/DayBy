import 'package:flutter/material.dart';

/// Raw palette from the Figma file (pages «дизайн» and «нужное»).
abstract final class AppPalette {
  static const accent = Color(0xFFDB827F);
  static const olive = Color(0xFF5E604D);
  static const oliveShadow = Color(0xFF8F6B6B);
  static const oliveDarkShadow = Color(0xFF4D4D41);
  static const beige = Color(0xFFFFE9DA);
  static const elevation = Color(0xFFFFF8F2);
  static const stroke = Color(0xFFD5CCC5);
  static const muted = Color(0xFFA19DA4);
  static const pinkEnd = Color(0xFFEA9692);

  static const darkBg = Color(0xFF121614);
  static const darkElevation = Color(0xFF1E2421);

  /// Accent colours offered in profile → «Акцентные цвета».
  static const accentOptions = <Color>[
    accent,
    Color(0xFF5AB8F8),
    Color(0xFFFFB664),
    Color(0xFF8FD45A),
    Color(0xFF6E82FA),
    Color(0xFFC865FA),
  ];
}

/// Semantic colours used by widgets, resolved per theme and accent.
@immutable
class DayByColors extends ThemeExtension<DayByColors> {
  const DayByColors({
    required this.accent,
    required this.background,
    required this.backgroundGradient,
    required this.card,
    required this.elevation,
    required this.stroke,
    required this.text,
    required this.muted,
    required this.primary,
    required this.onPrimary,
    required this.primaryShadow,
    required this.glass,
  });

  final Color accent;
  final Color background;
  final Gradient backgroundGradient;
  final Color card;
  final Color elevation;
  final Color stroke;
  final Color text;
  final Color muted;
  final Color primary;
  final Color onPrimary;
  final Color primaryShadow;
  final Color glass;

  factory DayByColors.light(Color accent) => DayByColors(
        accent: accent,
        background: AppPalette.beige,
        backgroundGradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          stops: [0.05, 1.0],
          colors: [Color(0xFFFFE9DB), Color(0xFFF2B9B3)],
        ),
        card: Colors.white,
        elevation: AppPalette.elevation,
        stroke: AppPalette.stroke,
        text: AppPalette.olive,
        muted: AppPalette.muted,
        primary: AppPalette.olive,
        onPrimary: Colors.white,
        primaryShadow: AppPalette.oliveShadow,
        glass: Colors.white.withValues(alpha: 0.2),
      );

  factory DayByColors.dark(Color accent) => DayByColors(
        accent: accent,
        background: AppPalette.darkBg,
        backgroundGradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppPalette.darkBg, AppPalette.darkElevation],
        ),
        card: AppPalette.darkElevation,
        elevation: AppPalette.darkElevation,
        stroke: AppPalette.stroke.withValues(alpha: 0.3),
        text: AppPalette.beige,
        muted: AppPalette.muted,
        primary: AppPalette.beige,
        onPrimary: AppPalette.olive,
        primaryShadow: Colors.black,
        glass: Colors.white.withValues(alpha: 0.08),
      );

  @override
  DayByColors copyWith({Color? accent}) => DayByColors(
        accent: accent ?? this.accent,
        background: background,
        backgroundGradient: backgroundGradient,
        card: card,
        elevation: elevation,
        stroke: stroke,
        text: text,
        muted: muted,
        primary: primary,
        onPrimary: onPrimary,
        primaryShadow: primaryShadow,
        glass: glass,
      );

  @override
  DayByColors lerp(DayByColors? other, double t) {
    if (other == null) return this;
    return DayByColors(
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundGradient:
          Gradient.lerp(backgroundGradient, other.backgroundGradient, t)!,
      card: Color.lerp(card, other.card, t)!,
      elevation: Color.lerp(elevation, other.elevation, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryShadow: Color.lerp(primaryShadow, other.primaryShadow, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
    );
  }
}

extension DayByColorsX on BuildContext {
  DayByColors get colors => Theme.of(this).extension<DayByColors>()!;
}
