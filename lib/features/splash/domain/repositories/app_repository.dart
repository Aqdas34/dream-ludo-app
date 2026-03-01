// ── app_repository.dart ──────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dream_ludo/core/error/failures.dart';
import 'package:dream_ludo/features/splash/data/models/app_model.dart';

abstract class AppRepository {
  Future<Either<Failure, AppModel>> getAppDetails();
}
