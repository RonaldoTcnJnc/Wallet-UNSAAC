import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/privacy/privacy_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_state.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/balance_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/firebase_status_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/movement_tile.dart';

/// Pantalla principal de Wallet UNSAAC (Sesión 1).
///
/// Muestra el resumen que entrega el repositorio y permite alternar el tema.
/// El cambio de tema lo resuelve `ThemeCubit`; la pantalla solo envía la
/// intención del usuario y se reconstruye cuando el estado cambia.
class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key, required this.firebaseStatus});

  final FirebaseStatus firebaseStatus;

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<BalanceCubit>().load();
  }

  Future<void> _reload() async {
    await context.read<BalanceCubit>().retry();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature se habilita en la Sesión 2.'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  static const List<Color> _seedPalette = [
    Color(0xFF7A1F2B),
    Color(0xFF3F51B5),
    Color(0xFF1E88E5),
    Color(0xFF2E7D32),
    Color(0xFFFB8C00),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = context.select((ThemeCubit cubit) => cubit.state.mode);
    final hideBalance = context.select(
      (PrivacyCubit cubit) => cubit.state.isHidden,
    );
    final themeTooltip = switch (themeMode) {
      ThemeMode.light => 'Tema claro. Cambiar a tema oscuro',
      ThemeMode.dark => 'Tema oscuro. Cambiar a tema del sistema',
      ThemeMode.system => 'Tema del sistema. Cambiar a tema claro',
    };
    final themeIcon = switch (themeMode) {
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    };

    return BlocBuilder<BalanceCubit, BalanceState>(
      builder: (context, state) {
        if (state is BalanceLoading || state is BalanceInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is BalanceFailure) {
          return _ErrorView(message: state.message, onRetry: _reload);
        }

        final summary = (state as BalanceSuccess).summary;

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            title: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Wallet UNSAAC',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: themeTooltip,
                icon: Icon(themeIcon),
                onPressed: () => context.read<ThemeCubit>().toggle(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Text(
                  'Hola, estudiante UNSAAC',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Este es el resumen de tus finanzas en noviembre de 2026.',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                BlocSelector<ThemeCubit, ThemeState, Color>(
                  selector: (state) => state.seedColor,
                  builder: (context, selectedSeed) {
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final color in _seedPalette)
                          GestureDetector(
                            onTap: () =>
                                context.read<ThemeCubit>().setSeedColor(color),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedSeed == color
                                      ? theme.colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: selectedSeed == color
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                BalanceCard(
                  summary: summary,
                  hideBalance: hideBalance,
                  onToggle: () => context.read<PrivacyCubit>().toggle(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _showComingSoon('Registrar ingreso'),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Ingreso'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showComingSoon('Registrar egreso'),
                        icon: const Icon(Icons.remove_rounded),
                        label: const Text('Egreso'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Últimos movimientos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showComingSoon('El historial completo'),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (summary.isEmpty)
                  const _EmptyMovements()
                else
                  for (final movement in summary.movements) ...[
                    MovementTile(movement: movement, hideAmount: hideBalance),
                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 12),
                FirebaseStatusCard(status: widget.firebaseStatus),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Datos de demostración · Wallet UNSAAC 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 56, color: scheme.error),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Revisa la conexión y vuelve a intentarlo.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMovements extends StatelessWidget {
  const _EmptyMovements();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            const Text('Todavía no registraste movimientos.'),
          ],
        ),
      ),
    );
  }
}
