// ───────────────────────────────────────────────────────────────
// login_usecase.dart  –  Login use case
// ───────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dream_ludo/core/error/failures.dart';
import 'package:dream_ludo/features/auth/data/models/user_model.dart';
import 'package:dream_ludo/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<Either<Failure, UserModel>> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
      type: params.type,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  final String type; // 'regular' | 'social'

  const LoginParams({
    required this.email,
    required this.password,
    this.type = 'regular',
  });

  @override
  List<Object> get props => [email, password, type];
}
