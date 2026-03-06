// ───────────────────────────────────────────────────────────────
// auth_repository.dart  –  Abstract auth repository contract
// ───────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dream_ludo/core/error/failures.dart';
import 'package:dream_ludo/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
    required String type, // 'regular' or 'social'
  });

  Future<Either<Failure, UserModel>> register({
    required String fullName,
    required String username,
    required String email,
    required String countryCode,
    required String mobile,
    required String password,
    required String fcmToken,
    required String deviceId,
    required String gender,
    String? referCode,
  });

  Future<Either<Failure, UserModel>> getProfile(String userId);

  Future<Either<Failure, UserModel>> updateProfile(String userId, Map<String, dynamic> data);

  Future<Either<Failure, UserModel>> verifyRegister({
    required String deviceId,
    required String mobile,
    required String email,
    required String username,
  });

  Future<Either<Failure, UserModel>> verifyMobile(String mobile);
  Future<Either<Failure, UserModel>> verifyRefer(String referCode);

  Future<Either<Failure, UserModel>> resetPassword({
    required String mobile,
    required String password,
  });

  Future<Either<Failure, void>> logout();
}
