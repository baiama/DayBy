import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/appearance.dart';

/// App preferences beyond appearance. Stored in SharedPreferences for now;
/// notifications are UI only until Firebase Messaging is wired up.
@immutable
class Settings {
  const Settings({
    this.reminders = true,
    this.dailyDigest = true,
    this.digestTime = const TimeOfDay(hour: 9, minute: 0),
    this.sound = true,
    this.weekStartsMonday = true,
    this.showCompleted = true,
    this.defaultReminder = const TimeOfDay(hour: 10, minute: 0),
    this.language = 'ru',
  });

  final bool reminders;
  final bool dailyDigest;
  final TimeOfDay digestTime;
  final bool sound;
  final bool weekStartsMonday;
  final bool showCompleted;
  final TimeOfDay defaultReminder;
  final String language;

  Settings copyWith({
    bool? reminders,
    bool? dailyDigest,
    TimeOfDay? digestTime,
    bool? sound,
    bool? weekStartsMonday,
    bool? showCompleted,
    TimeOfDay? defaultReminder,
    String? language,
  }) => Settings(
    reminders: reminders ?? this.reminders,
    dailyDigest: dailyDigest ?? this.dailyDigest,
    digestTime: digestTime ?? this.digestTime,
    sound: sound ?? this.sound,
    weekStartsMonday: weekStartsMonday ?? this.weekStartsMonday,
    showCompleted: showCompleted ?? this.showCompleted,
    defaultReminder: defaultReminder ?? this.defaultReminder,
    language: language ?? this.language,
  );
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<Settings> {
  static const _p = 'settings.';

  @override
  Settings build() {
    final prefs = ref.watch(sharedPrefsProvider);
    TimeOfDay? time(String k) {
      final m = prefs.getInt('$_p$k');
      return m == null ? null : TimeOfDay(hour: m ~/ 60, minute: m % 60);
    }

    const d = Settings();
    return Settings(
      reminders: prefs.getBool('${_p}reminders') ?? d.reminders,
      dailyDigest: prefs.getBool('${_p}dailyDigest') ?? d.dailyDigest,
      digestTime: time('digestTime') ?? d.digestTime,
      sound: prefs.getBool('${_p}sound') ?? d.sound,
      weekStartsMonday: prefs.getBool('${_p}weekStartsMonday') ?? d.weekStartsMonday,
      showCompleted: prefs.getBool('${_p}showCompleted') ?? d.showCompleted,
      defaultReminder: time('defaultReminder') ?? d.defaultReminder,
      language: prefs.getString('${_p}language') ?? d.language,
    );
  }

  void _bool(String key, bool v, Settings next) {
    state = next;
    ref.read(sharedPrefsProvider).setBool('$_p$key', v);
  }

  void _time(String key, TimeOfDay v, Settings next) {
    state = next;
    ref.read(sharedPrefsProvider).setInt('$_p$key', v.hour * 60 + v.minute);
  }

  void setReminders(bool v) => _bool('reminders', v, state.copyWith(reminders: v));
  void setDailyDigest(bool v) => _bool('dailyDigest', v, state.copyWith(dailyDigest: v));
  void setSound(bool v) => _bool('sound', v, state.copyWith(sound: v));
  void setWeekStartsMonday(bool v) =>
      _bool('weekStartsMonday', v, state.copyWith(weekStartsMonday: v));
  void setShowCompleted(bool v) => _bool('showCompleted', v, state.copyWith(showCompleted: v));
  void setDigestTime(TimeOfDay v) => _time('digestTime', v, state.copyWith(digestTime: v));
  void setDefaultReminder(TimeOfDay v) =>
      _time('defaultReminder', v, state.copyWith(defaultReminder: v));

  void setLanguage(String v) {
    state = state.copyWith(language: v);
    ref.read(sharedPrefsProvider).setString('${_p}language', v);
  }
}

/// Whether the intro slides were shown on this device.
final onboardingDoneProvider = NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<bool> {
  static const _key = 'onboarding.done';

  @override
  bool build() => ref.watch(sharedPrefsProvider).getBool(_key) ?? false;

  void complete() {
    state = true;
    ref.read(sharedPrefsProvider).setBool(_key, true);
  }
}
