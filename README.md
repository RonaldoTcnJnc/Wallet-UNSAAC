# Wallet UNSAAC

Aplicativo académico de finanzas personales del curso **Desarrollo de Software II**
de la Escuela Profesional de Ingeniería Informática y de Sistemas de la UNSAAC.
Autor: **RonaldoTcnJnc**.

La aplicación usa arquitectura por capas, Material 3, estado con Cubit y Firebase
Core configurado para Android y Web. El Reto 1 añade persistencia del tema. Los
movimientos financieros siguen siendo datos de demostración en memoria; no se ha
implementado autenticación ni persistencia en Firestore.

## Funcionalidad actual

- Resumen con ingresos, egresos, saldo y siete movimientos de demostración.
- Tema claro, oscuro o del sistema, con la preferencia guardada entre sesiones.
- Firebase Core inicializado en Android y Web. Linux puede ejecutar la app en modo
   local; FlutterFire no ofrece soporte oficial directo para Firebase en Linux.
- Retos 2, 3 y 4 todavía pendientes: saldo privado, estados del saldo con Cubit y
   color semilla configurable.

## Estado verificado

| Verificación | Resultado |
|---|---|
| Flutter / Dart | Flutter 3.47.8 · Dart 3.13.7 (canal estable) |
| `flutter analyze` | Sin observaciones |
| `flutter test` | 19 pruebas aprobadas |
| `flutter build web` | Compilación correcta |
| Android | Ejecutada en emulador; Firebase muestra «conectado» |
| Firebase | Proyecto `wallet-unsaac-bb1b5`; apps Android y Web registradas |
| Android applicationId | `pe.edu.unsaac.wallet_unsaac` |

Las capturas de evidencia se guardan fuera del repositorio, en
`../evidencias_wallet_unsaac/`: `firebase-android.png` y `firebase-web.png`.

## Requisitos

- Flutter 3.47.8 o superior (canal estable) y Dart 3.13.7 o superior.
- Android Studio con SDK de Android y un emulador con Google Play, o un
  dispositivo físico con depuración USB.
- Node.js/npm, Firebase CLI y FlutterFire CLI para configurar Firebase.
- Git.

## Puesta en marcha

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

`flutter run` abre la app en el dispositivo disponible. Para Web usa
`flutter run -d chrome`. El saldo de demostración es `S/ 1,274.60`.

### Configurar Firebase

El proyecto Firebase usado es `wallet-unsaac-bb1b5`; contiene una app Android
(`pe.edu.unsaac.wallet_unsaac`) y una app Web. Para regenerar la configuración en
un entorno nuevo, inicia sesión con una cuenta de Google autorizada en Firebase y
ejecuta:

```bash
npm install --global firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=wallet-unsaac-bb1b5 --platforms=android,web
```

FlutterFire genera `lib/firebase_options.dart`, registra las aplicaciones que
falten y prepara la configuración Android. Ejecuta `flutter pub get` y luego
`flutter run`; en Android y Web la tarjeta debe mostrar «Firebase: conectado».
El archivo `android/app/google-services.json` es local y está excluido de Git; no
lo agregues al repositorio. La configuración Android y Web se regenera con
`flutterfire configure` cuando sea necesario.

Si cambias el `applicationId` en `android/app/build.gradle.kts`, registra ese
mismo identificador en Firebase Console y vuelve a ejecutar FlutterFire. Firebase
Core no tiene soporte oficial directo de FlutterFire para Linux; esa plataforma
abre en modo local.

## Estructura del proyecto

```text
lib/
├── main.dart                      # ensureInitialized → Firebase → runApp
├── app.dart                       # providers, MaterialApp y tema
├── firebase_options.dart          # opciones Android/Web generadas por FlutterFire
├── core/
│   ├── config/
│   │   ├── firebase_bootstrap.dart
│   │   └── firebase_status.dart
│   ├── theme/
│   │   ├── app_theme.dart         # ColorScheme.fromSeed (claro/oscuro)
│   │   ├── theme_cubit.dart       # lógica del tema
│   │   ├── theme_preferences.dart # persistencia con SharedPreferences
│   │   └── theme_state.dart       # estado inmutable con Equatable
│   └── utils/
│       └── money.dart             # formato de soles y fechas
└── features/
    └── wallet/
        ├── domain/
        │   ├── entities/
        │   │   ├── movement.dart
        │   │   └── wallet_summary.dart
        │   └── repositories/
        │       └── wallet_repository.dart
        ├── data/
        │   └── repositories/
        │       └── in_memory_wallet_repository.dart
        └── presentation/
            ├── pages/
            │   └── wallet_home_page.dart
            └── widgets/
                ├── balance_card.dart
                ├── firebase_status_card.dart
                └── movement_tile.dart
```

Las pruebas están en `test/`. La regla de dependencia es unidireccional:

```text
presentation → domain ← data
```

- `presentation` conoce `domain`, nunca `data`.
- `data` implementa las interfaces de `domain`.
- `domain` no importa Flutter, Firebase ni HTTP.

El diagrama editable está en [`docs/arquitectura.md`](docs/arquitectura.md).

## Flujo BLoC de la sesión

```text
La app inicia
        │
        ▼
ThemePreferences.loadMode()             (lee SharedPreferences antes de runApp)
        │
        ▼
ThemeCubit(ThemeState(mode: ...))        (estado inicial recuperado)
        │
        ▼
Usuario pulsa el icono → toggle()        (claro → oscuro → sistema)
        │
        ▼
ThemeCubit emite y guarda el nuevo modo  (Equatable + SharedPreferences)
   │
   ▼
BlocBuilder → MaterialApp(themeMode: state.mode)
```

`ThemeCubit` es un **Cubit** (no un Bloc con eventos): la intención se expresa
con un método y el estado se emite directamente. El modo elegido se carga antes
de `runApp` y se guarda al cambiarlo. El botón recorre claro → oscuro → sistema.

## Decisiones de diseño

1. **Estado inmutable con `Equatable`.** `ThemeState` implementa `props`, de
   modo que BLoC puede comparar estados por valor y evitar reconstrucciones
   innecesarias.
2. **Tema persistente.** `ThemePreferences` separa el almacenamiento del Cubit;
   los valores ausentes o inválidos vuelven a `ThemeMode.system`.
3. **Repositorio abstracto.** `WalletRepository` aísla la fuente de datos. En
   la Sesión 5 se reemplaza `InMemoryWalletRepository` por Firestore sin tocar
   la pantalla.
4. **Firebase defensivo.** `FirebaseBootstrap` distingue credenciales ausentes,
   inicialización correcta y error. La app nunca se queda en pantalla blanca.
5. **Permiso de Internet en el manifiesto principal.** La plantilla de Flutter
   solo lo declara en `debug` y `profile`; sin el permiso en `main`, un APK de
   release no puede hablar con Firebase ni con una API REST.
6. **Configuración Firebase de cliente.** `lib/firebase_options.dart` contiene
   opciones públicas de cliente generadas por FlutterFire; no contiene claves de
   cuenta de servicio. `google-services.json`, `key.properties` y los almacenes
   de claves se mantienen fuera del repositorio. La autorización de datos debe
   protegerse con reglas de Firebase y restricciones de API.

## Pruebas incluidas

| Archivo | Qué verifica |
|---|---|
| `test/theme_cubit_test.dart` | Estado inicial, ciclo de modos, `setMode` y `useSystemMode`. |
| `test/theme_preferences_test.dart` | Guardar/recuperar, persistencia desde Cubit y fallback ante valores inválidos. |
| `test/wallet_summary_test.dart` | Cálculo de ingresos, egresos y saldo en el dominio. |
| `test/money_format_test.dart` | Formato `S/ 1,274.60` y fechas `dd/mm/aaaa`. |
| `test/in_memory_wallet_repository_test.dart` | Totales de los datos de demostración. |
| `test/widget_test.dart` | Saldo visible y ciclo de tres modos en la interfaz. |

## Errores frecuentes

| Síntoma | Causa probable | Solución |
|---|---|---|
| «Firebase: no configurado» | Opciones ausentes para la plataforma | Ejecutar `flutterfire configure` para Android y Web. |
| `FirebaseException: API key not valid` | `applicationId` distinto al registrado | Registrar la app con el mismo `applicationId` y regenerar opciones. |
| La app funciona en debug pero no en release | Falta `INTERNET` en el manifiesto principal | Verificar `android/app/src/main/AndroidManifest.xml`. |
| Firebase no conecta en Linux | FlutterFire no soporta oficialmente Linux | La app funciona en modo local en esa plataforma. |
| Gradle falla por ruta con acentos | Ruta del proyecto con caracteres no ASCII | Mover el proyecto a una ruta ASCII, por ejemplo `~/dev/wallet_unsaac`. |

## Referencias

- Bloc Library. (2026). *Bloc library documentation*. https://bloclibrary.dev/
- Google. (2026). *Flutter documentation*. https://docs.flutter.dev/
- Google. (2026). *Firebase documentation*. https://firebase.google.com/docs
- Google. (2026). *Build and release an Android app*. https://docs.flutter.dev/deployment/android
- Jiménez, A. (s. f.). *Curso de Flutter con Firebase*. Platzi. https://platzi.com/cursos/flutter-firebase/

## Licencia y uso académico

Material elaborado para el curso IF616AIN de la UNSAAC. El código puede usarse
libremente con fines académicos; se agradece citar la fuente.
