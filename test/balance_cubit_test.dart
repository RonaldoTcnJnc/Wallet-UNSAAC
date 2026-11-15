import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_state.dart';

class _FakeWalletRepository implements WalletRepository {
  _FakeWalletRepository({this.summary, this.error});

  final WalletSummary? summary;
  final Object? error;
  int calls = 0;

  @override
  Future<WalletSummary> loadSummary() async {
    calls++;
    final localError = error;
    if (localError != null) {
      throw localError;
    }
    return summary ?? const WalletSummary(movements: []);
  }
}

void main() {
  final demoSummary = WalletSummary(
    movements: [
      Movement(
        id: 'm1',
        title: 'Ingreso',
        category: 'Trabajo',
        amount: 1200,
        type: MovementType.income,
        date: DateTime(2026, 11, 10),
      ),
    ],
  );

  blocTest<BalanceCubit, BalanceState>(
    'emite loading y luego success cuando el repositorio responde',
    build: () => BalanceCubit(_FakeWalletRepository(summary: demoSummary)),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<BalanceLoading>(),
      isA<BalanceSuccess>(),
    ],
    verify: (cubit) {
      expect((cubit.state as BalanceSuccess).summary.balance, 1200);
    },
  );

  blocTest<BalanceCubit, BalanceState>(
    'emite failure cuando el repositorio lanza una excepción',
    build: () => BalanceCubit(_FakeWalletRepository(error: Exception('error'))),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<BalanceLoading>(),
      isA<BalanceFailure>(),
    ],
  );

  blocTest<BalanceCubit, BalanceState>(
    'reintenta la carga con el repositorio y vuelve a success',
    build: () => BalanceCubit(_FakeWalletRepository(summary: demoSummary)),
    act: (cubit) async {
      await cubit.load();
      await cubit.retry();
    },
    expect: () => [
      isA<BalanceLoading>(),
      isA<BalanceSuccess>(),
      isA<BalanceLoading>(),
      isA<BalanceSuccess>(),
    ],
  );
}
