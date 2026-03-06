// ───────────────────────────────────────────────────────────────
// register_usecase.dart  –  Register use case
// ───────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dream_ludo/core/error/failures.dart';
import 'package:dream_ludo/features/auth/data/models/user_model.dart';
import 'package:dream_ludo/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<Either<Failure, UserModel>> call(RegisterParams params) {
    return _repository.register(
      fullName: params.fullName,
      username: params.username,
      email: params.email,
      countryCode: params.countryCode,
      mobile: params.mobile,
      password: params.password,
      fcmToken: params.fcmToken,
      deviceId: params.deviceId,
      gender: params.gender,
      referCode: params.referCode,
    );
  }
}

class RegisterParams extends Equatable {
  final String fullName;
  final String username;
  final String email;
  final String countryCode;
  final String mobile;
  final String password;
  final String fcmToken;
  final String deviceId;
  final String gender;
  final String? referCode;

  const RegisterParams({
    required this.fullName,
    required this.username,
    required this.email,
    required this.countryCode,
    required this.mobile,
    required this.password,
    required this.fcmToken,
    required this.deviceId,
    required this.gender,
    this.referCode,
  });

  @override
  List<Object?> get props => [email, mobile, gender];
}
