// ── match_repository.dart  –  Match abstract contract ─────────

import 'package:dartz/dartz.dart';
import 'package:dream_ludo/core/error/failures.dart';
import 'package:dream_ludo/features/match/data/models/match_model.dart';

abstract class MatchRepository {
  Future<Either<Failure, List<MatchModel>>> getUpcoming(String userId);
  Future<Either<Failure, List<MatchModel>>> getOngoing(String userId);
  Future<Either<Failure, List<MatchModel>>> getCompleted(String userId);
  Future<Either<Failure, MatchModel>> joinMatch(String matchId, String userId);
  Future<Either<Failure, MatchModel>> leaveMatch(String matchId, String userId);
  Future<Either<Failure, MatchModel>> submitResult({
    required String matchId,
    required String userId,
    required String status,
    String? proofImage,
  });
}
