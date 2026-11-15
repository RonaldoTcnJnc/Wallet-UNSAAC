import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

class _MemoryThemePreferences implements ThemePreferences {
  @override
  Future<ThemeMode> loadMode() async => ThemeMode.system;

  @override
  Future<void> saveMode(ThemeMode mode) async {}
}

WalletApp _createApp() => WalletApp(
  firebaseStatus: const FirebaseStatus.notConfigured(),
  themePreferences: _MemoryThemePreferences(),
  initialThemeMode: ThemeMode.system,
);

void main() {
  testWidgets('la pantalla principal muestra el saldo de demostración', (
    tester,
  ) async {
    await tester.pumpWidget(_createApp());
    await tester.pumpAndSettle();

    expect(find.text('Wallet UNSAAC'), findsOneWidget);
    expect(find.text('Saldo disponible'), findsOneWidget);
    expect(find.text('S/ 1,274.60'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Firebase: no configurado (modo local)'),
      find.byType(ListView),
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(find.text('Firebase: no configurado (modo local)'), findsOneWidget);
  });

  testWidgets('el botón recorre los tres modos y refleja el modo actual', (
    tester,
  ) async {
    await tester.pumpWidget(_createApp());
    await tester.pumpAndSettle();

    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app().themeMode, ThemeMode.system);
    expect(
      find.byTooltip('Tema del sistema. Cambiar a tema claro'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Tema del sistema. Cambiar a tema claro'));
    await tester.pumpAndSettle();

    expect(app().themeMode, ThemeMode.light);
    expect(find.byTooltip('Tema claro. Cambiar a tema oscuro'), findsOneWidget);

    await tester.tap(find.byTooltip('Tema claro. Cambiar a tema oscuro'));
    await tester.pumpAndSettle();
    expect(app().themeMode, ThemeMode.dark);

    await tester.tap(find.byTooltip('Tema oscuro. Cambiar a tema del sistema'));
    await tester.pumpAndSettle();
    expect(app().themeMode, ThemeMode.system);
  });
}
