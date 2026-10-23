import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

enum TextSize {
  small('маленький', 0.9),
  medium('средний', 1.0),
  large('крупный', 1.15);

  const TextSize(this.label, this.scale);
  final String label;
  final double scale;
}

@immutable
class Appearance {
  const Appearance({
    this.themeMode = ThemeMode.system,
    this.accent = AppPalette.accent,
    this.textSize = TextSize.medium,
  });

  final ThemeMode themeMode;
  final Color accent;
  final TextSize textSize;

  Appearance copyWith({ThemeMode? themeMode, Color? accent, TextSize? textSize}) =>
      Appearance(
        themeMode: themeMode ?? this.themeMode,
        accent: accent ?? this.accent,
        textSize: textSize ?? this.textSize,
      );
}

/// Overridden in main() with the loaded instance.
final sharedPrefsProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

final appearanceProvider =
    NotifierProvider<AppearanceNotifier, Appearance>(AppearanceNotifier.new);

class AppearanceNotifier extends Notifier<Appearance> {
  static const _themeKey = 'appearance.theme';
  static const _accentKey = 'appearance.accent';
  static const _textKey = 'appearance.text';

  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  Appearance build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final accent = prefs.getInt(_accentKey);
    return Appearance(
      themeMode: ThemeMode.values[prefs.getInt(_themeKey) ?? 0],
      accent: accent == null ? AppPalette.accent : Color(accent),
      textSize: TextSize.values[prefs.getInt(_textKey) ?? 1],
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setInt(_themeKey, mode.index);
  }

  void setAccent(Color color) {
    state = state.copyWith(accent: color);
    _prefs.setInt(_accentKey, color.toARGB32());
  }

  void setTextSize(TextSize size) {
    state = state.copyWith(textSize: size);
    _prefs.setInt(_textKey, size.index);
  }
}
