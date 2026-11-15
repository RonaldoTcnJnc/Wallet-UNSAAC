import 'package:equatable/equatable.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';

sealed class BalanceState extends Equatable {
  const BalanceState();
}

class BalanceInitial extends BalanceState {
  const BalanceInitial();

  @override
  List<Object?> get props => [];
}

class BalanceLoading extends BalanceState {
  const BalanceLoading();

  @override
  List<Object?> get props => [];
}

class BalanceSuccess extends BalanceState {
  const BalanceSuccess(this.summary);

  final WalletSummary summary;

  @override
  List<Object?> get props => [summary];
}

class BalanceFailure extends BalanceState {
  const BalanceFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
