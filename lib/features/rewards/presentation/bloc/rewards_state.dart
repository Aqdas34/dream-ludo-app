import 'package:equatable/equatable.dart';
import '../../domain/models/reward_model.dart';

abstract class RewardsState extends Equatable {
  const RewardsState();
  @override
  List<Object?> get props => [];
}

class RewardsInitial extends RewardsState {}

class RewardsLoading extends RewardsState {}

class RewardsLoaded extends RewardsState {
  final RewardModel reward;
  const RewardsLoaded(this.reward);
  @override
  List<Object?> get props => [reward];
}

class RewardsError extends RewardsState {
  final String message;
  const RewardsError(this.message);
  @override
  List<Object?> get props => [message];
}
