import 'package:flutter/material.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_bootstrap.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

/// Punto de entrada de Wallet UNSAAC.
///
/// Orden obligatorio:
/// 1. `WidgetsFlutterBinding.ensureInitialized()` habilita los canales de
///    plataforma antes de tocar servicios nativos.
/// 2. Las preferencias del tema se leen antes de `runApp` para evitar un
///    cambio visual posterior al primer frame.
/// 3. Firebase se inicializa de forma defensiva; sin credenciales, la app abre
///    en modo local con datos de demostración.
/// 4. `runApp` construye el árbol de widgets.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themePreferences = await SharedPreferencesThemePreferences.create();
  final initialThemeMode = await themePreferences.loadMode();
  final firebaseStatus = await FirebaseBootstrap.initialize();
  runApp(
    WalletApp(
      firebaseStatus: firebaseStatus,
      themePreferences: themePreferences,
      initialThemeMode: initialThemeMode,
    ),
  );
}
