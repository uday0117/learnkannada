import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized service to manage app theme mode (Light, Dark, System)
/// with persistence via SharedPreferences.
class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _prefKey = 'app_theme_mode';
  late SharedPreferences _prefs;

  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Initialize theme mode from persistent storage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedMode = _prefs.getString(_prefKey);

    if (savedMode == 'light') {
      themeMode.value = ThemeMode.light;
    } else if (savedMode == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.system;
    }
  }

  /// Change theme mode and persist
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _prefs.setString(_prefKey, value);
  }

  /// Toggle between Light and Dark mode
  Future<void> toggleTheme(BuildContext context) async {
    final isCurrentlyDark = themeMode.value == ThemeMode.dark ||
        (themeMode.value == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    await setThemeMode(isCurrentlyDark ? ThemeMode.light : ThemeMode.dark);
  }
}
