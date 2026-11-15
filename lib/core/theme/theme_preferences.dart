import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ThemePreferences {
  Future<ThemeMode> loadMode();

  Future<void> saveMode(ThemeMode mode);
}

class SharedPreferencesThemePreferences implements ThemePreferences {
  SharedPreferencesThemePreferences(this._preferences);

  static const _modeKey = 'theme_mode';

  final SharedPreferences _preferences;

  static Future<SharedPreferencesThemePreferences> create() async {
    return SharedPreferencesThemePreferences(
      await SharedPreferences.getInstance(),
    );
  }

  @override
  Future<ThemeMode> loadMode() async {
    try {
      final storedMode = _preferences.getString(_modeKey);
      if (storedMode == null) return ThemeMode.system;

      return ThemeMode.values.firstWhere(
        (mode) => mode.name == storedMode,
        orElse: () => ThemeMode.system,
      );
    } catch (_) {
      return ThemeMode.system;
    }
  }

  @override
  Future<void> saveMode(ThemeMode mode) async {
    await _preferences.setString(_modeKey, mode.name);
  }
}