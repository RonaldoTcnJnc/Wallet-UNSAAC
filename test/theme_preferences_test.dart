import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesThemePreferences', () {
    test('guarda y recupera el modo elegido', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = SharedPreferencesThemePreferences(
        await SharedPreferences.getInstance(),
      );

      await preferences.saveMode(ThemeMode.dark);

      expect(await preferences.loadMode(), ThemeMode.dark);
    });

    test('persiste el modo elegido desde ThemeCubit', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = SharedPreferencesThemePreferences(
        await SharedPreferences.getInstance(),
      );
      final cubit = ThemeCubit(themePreferences: preferences);

      await cubit.setMode(ThemeMode.dark);

      expect(await preferences.loadMode(), ThemeMode.dark);
      await cubit.close();
    });

    test('usa modo sistema cuando el valor guardado no se reconoce', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'sepia'});
      final preferences = SharedPreferencesThemePreferences(
        await SharedPreferences.getInstance(),
      );

      expect(await preferences.loadMode(), ThemeMode.system);
    });

    test(
      'usa modo sistema cuando el valor guardado tiene un tipo incorrecto',
      () async {
        SharedPreferences.setMockInitialValues({'theme_mode': 7});
        final preferences = SharedPreferencesThemePreferences(
          await SharedPreferences.getInstance(),
        );

        expect(await preferences.loadMode(), ThemeMode.system);
      },
    );

    test('usa modo sistema cuando no existe una preferencia', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = SharedPreferencesThemePreferences(
        await SharedPreferences.getInstance(),
      );

      expect(await preferences.loadMode(), ThemeMode.system);
    });
  });
}
