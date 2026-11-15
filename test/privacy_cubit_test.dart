import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/privacy/privacy_cubit.dart';
import 'package:wallet_unsaac/core/privacy/privacy_state.dart';
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
  group('PrivacyCubit', () {
    blocTest<PrivacyCubit, PrivacyState>(
      'emite un estado oculto al alternar',
      build: PrivacyCubit.new,
      act: (cubit) => cubit.toggle(),
      expect: () => const [PrivacyState(isHidden: true)],
    );

    test('el estado inicial muestra los importes', () {
      final cubit = PrivacyCubit();
      expect(cubit.state.isHidden, isFalse);
      cubit.close();
    });
  });

  testWidgets('el saldo y los movimientos se enmascaran al ocultar', (tester) async {
    await tester.pumpWidget(_createApp());
    await tester.pumpAndSettle();

    expect(find.text('S/ 1,274.60'), findsOneWidget);

    await tester.tap(find.byTooltip('Ocultar saldo'));
    await tester.pumpAndSettle();

    expect(find.text('S/ •••••'), findsNWidgets(3));
    expect(find.textContaining('••••'), findsWidgets);

    await tester.tap(find.byTooltip('Mostrar saldo'));
    await tester.pumpAndSettle();

    expect(find.text('S/ 1,274.60'), findsOneWidget);
    expect(find.text('S/ 1,770.00'), findsOneWidget);
    expect(find.text('S/ 495.40'), findsOneWidget);
    expect(find.text('+ S/ 1,200.00'), findsOneWidget);
    expect(find.textContaining('••••'), findsNothing);
  });
}
