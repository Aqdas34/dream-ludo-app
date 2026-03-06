// ── get_matches_usecase.dart ────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dream_ludo/core/error/failures.dart';
import 'package:dream_ludo/features/match/data/models/match_model.dart';
import 'package:dream_ludo/features/match/domain/repositories/match_repository.dart';

enum MatchTab { history, public, upcoming, ongoing, completed }

class GetMatchesUseCase {
  final MatchRepository _repository;
  GetMatchesUseCase(this._repository);

  Future<Either<Failure, List<MatchModel>>> call({
    required String userId,
    required MatchTab tab,
  }) {
    switch (tab) {
      case MatchTab.history:
        return _repository.getHistory(userId);
      case MatchTab.upcoming:
        return _repository.getUpcoming(userId);
      case MatchTab.ongoing:
        return _repository.getOngoing(userId);
      case MatchTab.completed:
        return _repository.getCompleted(userId);
      case MatchTab.public:
        return Future.value(const Right([]));
    }
  }
}
