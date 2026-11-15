import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

class _MemoryThemePreferences implements ThemePreferences {
  ThemeMode mode = ThemeMode.system;

  @override
  Future<ThemeMode> loadMode() async => mode;

  @override
  Future<void> saveMode(ThemeMode mode) async {
    this.mode = mode;
  }
}

void main() {
  group('ThemeCubit', () {
    test('inicia en modo sistema por defecto', () {
      expect(
        ThemeCubit(themePreferences: _MemoryThemePreferences()).state.mode,
        ThemeMode.system,
      );
    });

    test('acepta un modo inicial explícito', () {
      expect(
        ThemeCubit(
          themePreferences: _MemoryThemePreferences(),
          initialMode: ThemeMode.dark,
        ).state.mode,
        ThemeMode.dark,
      );
    });

    blocTest<ThemeCubit, ThemeState>(
      'toggle recorre claro, oscuro y sistema',
      build: () => ThemeCubit(themePreferences: _MemoryThemePreferences()),
      act: (cubit) async {
        await cubit.toggle();
        await cubit.toggle();
        await cubit.toggle();
      },
      expect: () => const [
        ThemeState(mode: ThemeMode.light),
        ThemeState(mode: ThemeMode.dark),
        ThemeState(mode: ThemeMode.system),
      ],
    );

    blocTest<ThemeCubit, ThemeState>(
      'setMode emite el modo solicitado',
      build: () => ThemeCubit(themePreferences: _MemoryThemePreferences()),
      act: (cubit) => cubit.setMode(ThemeMode.dark),
      expect: () => const [ThemeState(mode: ThemeMode.dark)],
    );

    test('persiste los cambios realizados desde el Cubit', () async {
      final preferences = _MemoryThemePreferences();
      final cubit = ThemeCubit(themePreferences: preferences);

      await cubit.setMode(ThemeMode.dark);

      expect(preferences.mode, ThemeMode.dark);
      await cubit.close();
    });

    blocTest<ThemeCubit, ThemeState>(
      'useSystemMode vuelve a seguir la preferencia del dispositivo',
      build: () => ThemeCubit(
        themePreferences: _MemoryThemePreferences(),
        initialMode: ThemeMode.dark,
      ),
      act: (cubit) => cubit.useSystemMode(),
      expect: () => const [ThemeState(mode: ThemeMode.system)],
    );
  });
}
