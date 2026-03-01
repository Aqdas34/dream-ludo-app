// ───────────────────────────────────────────────────────────────
// auth_remote_datasource.dart  –  Auth API calls via Dio
// Mirrors: Java → ApiCalling.java (login/register methods)
// ───────────────────────────────────────────────────────────────

import 'package:dream_ludo/core/constants/api_constants.dart';
import 'package:dream_ludo/core/constants/app_constants.dart';
import 'package:dream_ludo/core/network/dio_client.dart';
import 'package:dream_ludo/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
    required String type,
  });

  Future<UserModel> register({
    required String fullName,
    required String username,
    required String email,
    required String countryCode,
    required String mobile,
    required String password,
    required String fcmToken,
    required String deviceId,
    String? referCode,
  });

  Future<UserModel> verifyRegister({
    required String deviceId,
    required String mobile,
    required String email,
    required String username,
  });

  Future<UserModel> verifyMobile(String mobile);

  Future<UserModel> verifyRefer(String referCode);

  Future<UserModel> resetPassword({
    required String mobile,
    required String password,
  });

  Future<UserModel> updateFcmToken({
    required String userId,
    required String fcmToken,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    required String type,
  }) async {
    final response = await _client.get(
      ApiConstants.getUserLogin,
      queryParams: {
        'purchase_key': AppConstants.purchaseKey,
        'username': email,
        'password': password,
        'type': type,
      },
    );
    final data = UserResponse.fromJson(response.data);
    final result = data.result?.first;
    if (result == null) throw Exception('Empty response');
    return result;
  }

  @override
  Future<UserModel> register({
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
    final Map<String, dynamic> formData = {
      'purchase_key': AppConstants.purchaseKey,
      'full_name': fullName,
      'username': username,
      'email': email,
      'country_code': countryCode,
      'mobile': mobile,
      'password': password,
      'fcm_token': fcmToken,
      'device_id': deviceId,
      if (referCode != null && referCode.isNotEmpty) 'referer': referCode,
    };
    final response = await _client.postForm(
      ApiConstants.postUserRegister,
      formData: formData,
    );
    final data = UserResponse.fromJson(response.data);
    final result = data.result?.first;
    if (result == null) throw Exception('Empty response');
    return result;
  }

  @override
  Future<UserModel> verifyRegister({
    required String deviceId,
    required String mobile,
    required String email,
    required String username,
  }) async {
    final response = await _client.get(
      ApiConstants.verifyRegister,
      queryParams: {
        'purchase_key': AppConstants.purchaseKey,
        'device_id': deviceId,
        'mobile': mobile,
        'email': email,
        'username': username,
      },
    );
    final data = UserResponse.fromJson(response.data);
    return data.result!.first;
  }

  @override
  Future<UserModel> verifyMobile(String mobile) async {
    final response = await _client.get(
      ApiConstants.verifyMobile,
      queryParams: {
        'purchase_key': AppConstants.purchaseKey,
        'mobile': mobile,
      },
    );
    final data = UserResponse.fromJson(response.data);
    return data.result!.first;
  }

  @override
  Future<UserModel> verifyRefer(String referCode) async {
    final response = await _client.get(
      ApiConstants.verifyRefer,
      queryParams: {
        'purchase_key': AppConstants.purchaseKey,
        'refer': referCode,
      },
    );
    final data = UserResponse.fromJson(response.data);
    return data.result!.first;
  }

  @override
  Future<UserModel> resetPassword({
    required String mobile,
    required String password,
  }) async {
    final response = await _client.postForm(
      ApiConstants.resetPassword,
      formData: {
        'purchase_key': AppConstants.purchaseKey,
        'mobile': mobile,
        'password': password,
      },
    );
    final data = UserResponse.fromJson(response.data);
    return data.result!.first;
  }

  @override
  Future<UserModel> updateFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    final response = await _client.postForm(
      ApiConstants.updateUserProfile,
      formData: {
        'purchase_key': AppConstants.purchaseKey,
        'id': userId,
        'fcm_token': fcmToken,
      },
    );
    final data = UserResponse.fromJson(response.data);
    return data.result!.first;
  }
}
