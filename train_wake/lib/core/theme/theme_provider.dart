import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';

/// Riverpod StateNotifier for ThemeMode (Light, Dark, System)
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const String _boxKey = 'theme_mode_key';

  void _loadTheme() {
    try {
      if (Hive.isBoxOpen('trip_state_box')) {
        final box = Hive.box('trip_state_box');
        final saved = box.get(_boxKey);
        if (saved == 'light') state = ThemeMode.light;
        if (saved == 'dark') state = ThemeMode.dark;
        if (saved == 'system') state = ThemeMode.system;
      }
    } catch (_) {}
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    try {
      if (Hive.isBoxOpen('trip_state_box')) {
        final box = Hive.box('trip_state_box');
        final val = mode == ThemeMode.light
            ? 'light'
            : (mode == ThemeMode.dark ? 'dark' : 'system');
        box.put(_boxKey, val);
      }
    } catch (_) {}
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
