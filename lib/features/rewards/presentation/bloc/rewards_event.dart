import 'package:equatable/equatable.dart';

abstract class RewardsEvent extends Equatable {
  const RewardsEvent();
  @override
  List<Object?> get props => [];
}

class LoadRewards extends RewardsEvent {}

class ClaimDailyReward extends RewardsEvent {}

class RedeemCoins extends RewardsEvent {
  final int amount;
  const RedeemCoins(this.amount);
  @override
  List<Object?> get props => [amount];
}
