import 'package:dartz/dartz.dart';
import 'package:dream_ludo/core/error/failures.dart';
import 'package:dream_ludo/features/auth/data/models/user_model.dart';
import 'package:dream_ludo/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, UserModel>> call(String userId, Map<String, dynamic> data) async {
    return await _repository.updateProfile(userId, data);
  }
}
