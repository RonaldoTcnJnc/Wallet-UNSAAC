import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';

import 'balance_state.dart';

class BalanceCubit extends Cubit<BalanceState> {
  BalanceCubit(this._repository) : super(const BalanceInitial());

  final WalletRepository _repository;

  Future<void> load() async {
    emit(const BalanceLoading());

    try {
      final summary = await _repository.loadSummary();
      if (isClosed) return;
      emit(BalanceSuccess(summary));
    } catch (error) {
      if (isClosed) return;
      emit(BalanceFailure(_messageFrom(error)));
    }
  }

  Future<void> retry() => load();

  String _messageFrom(Object error) {
    final message = error.toString();
    if (message.contains('Exception')) {
      return 'No se pudo cargar el resumen de la billetera.';
    }
    return 'No se pudo cargar el resumen de la billetera.';
  }
}
