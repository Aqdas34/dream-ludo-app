// ───────────────────────────────────────────────────────────────
// auth_repository_impl.dart  –  Concrete auth repository
// ───────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:dream_ludo/core/error/exceptions.dart';
import 'package:dream_ludo/core/error/failures.dart';
import 'package:dream_ludo/core/services/storage_service.dart';
import 'package:dream_ludo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dream_ludo/features/auth/data/models/user_model.dart';
import 'package:dream_ludo/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final StorageService _storage;

  AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
    required String type,
  }) async {
    try {
      final user = await _remote.login(
        email: email,
        password: password,
        type: type,
      );

      // DEBUG — prints the raw parsed user so we can see what the API returned
      // ignore: avoid_print
      print('🔑 LOGIN RAW: success=${user.success}, msg=${user.msg}, id=${user.id}, username=${user.username}');

      // Accept login if:
      //  • success == 1  (normal case)
      //  • success is null but id/username present (API omits success key)
      //  • msg is null or empty (some APIs don't include error message on success)
      final bool isSuccess =
          user.success == 1 ||
          (user.success == null && (user.id != null || user.username != null));

      if (isSuccess) {
        // Save the JWT token if available in the response
        if (user.token != null && user.token!.isNotEmpty) {
          await _storage.saveToken(user.token!);
          print('🔑 TOKEN SAVED: ${user.token}');
        }

        await _storage.saveUserProfile(
          userId:      user.id ?? '',
          fullName:    user.fullName ?? '',
          profilePhoto: user.profileImg ?? '',
          username:    user.username ?? '',
          email:       user.email ?? '',
          countryCode: user.countryCode ?? '',
          mobile:      user.mobile ?? '',
          whatsapp:    user.whatsappNo ?? '',
          password:    password,
        );
        return Right(user);
      } else {
        return Left(AuthFailure(user.msg ?? 'Login failed. Check credentials.'));
      }
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      // ignore: avoid_print
      print('🔴 LOGIN ERROR: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> register({
    required String fullName,
    required String username,
    required String email,
    required String countryCode,
    required String mobile,
    required String password,
    required String fcmToken,
    required String deviceId,
    String? referCode,
  }) async {
    try {
      final user = await _remote.register(
        fullName: fullName,
        username: username,
        email: email,
        countryCode: countryCode,
        mobile: mobile,
        password: password,
        fcmToken: fcmToken,
        deviceId: deviceId,
        referCode: referCode,
      );
      if (user.success == 1) {
        // Save token and profile to auto-login after register
        if (user.token != null && user.token!.isNotEmpty) {
           await _storage.saveToken(user.token!);
        }
        await _storage.saveUserProfile(
          userId: user.id ?? '',
          fullName: user.fullName ?? '',
          profilePhoto: user.profileImg ?? '',
          username: user.username ?? '',
          email: user.email ?? '',
          countryCode: user.countryCode ?? '',
          mobile: user.mobile ?? '',
          whatsapp: user.whatsappNo ?? '',
          password: password,
        );
        return Right(user);
      }
      return Left(AuthFailure(user.msg ?? 'Registration failed'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> verifyRegister({
    required String deviceId,
    required String mobile,
    required String email,
    required String username,
  }) async {
    try {
      final result = await _remote.verifyRegister(
        deviceId: deviceId,
        mobile: mobile,
        email: email,
        username: username,
      );
      if (result.success == 1) return Right(result);
      return Left(ValidationFailure(result.msg ?? 'Verification failed'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> verifyMobile(String mobile) async {
    try {
      final result = await _remote.verifyMobile(mobile);
      if (result.success == 1) return Right(result);
      return Left(ValidationFailure(result.msg ?? 'Mobile verification failed'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> verifyRefer(String referCode) async {
    try {
      final result = await _remote.verifyRefer(referCode);
      if (result.success == 1) return Right(result);
      return Left(ValidationFailure(result.msg ?? 'Invalid referral code'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> resetPassword({
    required String mobile,
    required String password,
  }) async {
    try {
      final result = await _remote.resetPassword(
        mobile: mobile,
        password: password,
      );
      if (result.success == 1) return Right(result);
      return Left(ServerFailure(result.msg ?? 'Reset failed'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _storage.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
