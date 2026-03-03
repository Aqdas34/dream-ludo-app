import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/reward_model.dart';
import 'rewards_event.dart';
import 'rewards_state.dart';

class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  RewardsBloc() : super(RewardsInitial()) {
    on<LoadRewards>(_onLoadRewards);
    on<ClaimDailyReward>(_onClaimDaily);
  }

  Future<void> _onLoadRewards(LoadRewards event, Emitter<RewardsState> emit) async {
    emit(RewardsLoading());
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    final mockData = RewardModel(
      coins: 1250,
      gems: 45,
      totalWins: 12,
      totalGames: 45,
      history: [
        RewardHistoryItem(
          amount: 50,
          type: 'DAILY_LOGIN',
          description: 'Daily Check-in',
          createdAt: DateTime.now(),
        ),
        RewardHistoryItem(
          amount: 100,
          type: 'GAME_WIN',
          description: 'Ludo Match Won',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );

    emit(RewardsLoaded(mockData));
  }

  Future<void> _onClaimDaily(ClaimDailyReward event, Emitter<RewardsState> emit) async {
    if (state is RewardsLoaded) {
      final current = (state as RewardsLoaded).reward;
      emit(RewardsLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updated = RewardModel(
        coins: current.coins + 50,
        gems: current.gems,
        totalWins: current.totalWins,
        totalGames: current.totalGames,
        history: [
          RewardHistoryItem(
            amount: 50,
            type: 'DAILY_LOGIN',
            description: 'Daily Reward Claimed',
            createdAt: DateTime.now(),
          ),
          ...current.history,
        ],
      );
      emit(RewardsLoaded(updated));
    }
  }
}
