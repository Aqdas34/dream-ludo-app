// ── get_app_details_usecase.dart ─────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dream_ludo/core/error/failures.dart';
import 'package:dream_ludo/features/splash/data/models/app_model.dart';
import 'package:dream_ludo/features/splash/domain/repositories/app_repository.dart';

class GetAppDetailsUseCase {
  final AppRepository _repository;
  GetAppDetailsUseCase(this._repository);

  Future<Either<Failure, AppModel>> call() => _repository.getAppDetails();
}
