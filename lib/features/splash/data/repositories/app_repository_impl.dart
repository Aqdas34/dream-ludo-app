// ── app_repository_impl.dart ─────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dream_ludo/core/error/exceptions.dart';
import 'package:dream_ludo/core/error/failures.dart';
import 'package:dream_ludo/features/splash/data/datasources/app_remote_datasource.dart';
import 'package:dream_ludo/features/splash/data/models/app_model.dart';
import 'package:dream_ludo/features/splash/domain/repositories/app_repository.dart';

class AppRepositoryImpl implements AppRepository {
  final AppRemoteDataSource _remote;
  AppRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, AppModel>> getAppDetails() async {
    try {
      final result = await _remote.getAppDetails();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
