// ── match_repository_impl.dart ─────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dream_ludo/core/error/exceptions.dart';
import 'package:dream_ludo/core/error/failures.dart';
import 'package:dream_ludo/features/match/data/datasources/match_remote_datasource.dart';
import 'package:dream_ludo/features/match/data/models/match_model.dart';
import 'package:dream_ludo/features/match/domain/repositories/match_repository.dart';

class MatchRepositoryImpl implements MatchRepository {
  final MatchRemoteDataSource _remote;
  MatchRepositoryImpl(this._remote);

  Either<Failure, T> _handleError<T>(Object e) {
    if (e is NetworkException) return Left(NetworkFailure(e.message));
    if (e is AppException) return Left(ServerFailure(e.message));
    return Left(UnknownFailure(e.toString()));
  }

  @override
  Future<Either<Failure, List<MatchModel>>> getHistory(String userId) async {
    try {
      return Right(await _remote.getHistory(userId));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, List<MatchModel>>> getUpcoming(String userId) async {
    try {
      return Right(await _remote.getUpcoming(userId));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, List<MatchModel>>> getOngoing(String userId) async {
    try {
      return Right(await _remote.getOngoing(userId));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, List<MatchModel>>> getCompleted(String userId) async {
    try {
      return Right(await _remote.getCompleted(userId));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, MatchModel>> joinMatch(
      String matchId, String userId) async {
    try {
      return Right(await _remote.joinMatch(matchId, userId));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, MatchModel>> leaveMatch(
      String matchId, String userId) async {
    try {
      return Right(await _remote.leaveMatch(matchId, userId));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, MatchModel>> submitResult({
    required String matchId,
    required String userId,
    required String status,
    String? proofImage,
  }) async {
    try {
      return Right(await _remote.submitResult(
        matchId: matchId,
        userId: userId,
        status: status,
        proofImage: proofImage,
      ));
    } catch (e) {
      return _handleError(e);
    }
  }
}
