import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

/// `Cubit` que gobierna el tema claro/oscuro.
///
/// Un Cubit es un BLoC sin eventos explícitos: la interfaz invoca métodos y el
/// Cubit emite estados. Es la opción recomendada cuando la lógica es simple y
/// no requiere trazabilidad de eventos.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({
    required ThemePreferences themePreferences,
    ThemeMode initialMode = ThemeMode.system,
  }) : _preferences = themePreferences,
       super(ThemeState(mode: initialMode));

  final ThemePreferences _preferences;

  /// Recorre los modos en el orden claro, oscuro y sistema.
  Future<void> toggle() {
    final nextMode = switch (state.mode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    return setMode(nextMode);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == state.mode) return;
    emit(state.copyWith(mode: mode));
    await _preferences.saveMode(mode);
  }

  Future<void> useSystemMode() => setMode(ThemeMode.system);
}
