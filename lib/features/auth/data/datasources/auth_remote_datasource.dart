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
    required String gender,
    String? referCode,
  });

  Future<UserModel> getProfile(String userId);

  Future<UserModel> updateProfile(String userId, Map<String, dynamic> data);

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

  void _checkSuccess(dynamic responseData) {
    if (responseData is Map) {
      final success = _safeInt(responseData['success']);
      final msg = responseData['msg']?.toString();
      if (success == 0) {
        throw Exception(msg ?? 'Operation failed');
      }
    }
  }

  int? _safeInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

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

    _checkSuccess(response.data);

    final data = UserResponse.fromJson(response.data);
    final result = data.result?.first;
    if (result == null) throw Exception('User data not found in response');
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
    required String gender,
    String? referCode,
  }) async {
    final Map<String, dynamic> bodyData = {
      'purchase_key': AppConstants.purchaseKey,
      'full_name': fullName,
      'username': username,
      'email': email,
      'country_code': countryCode,
      'mobile': mobile,
      'password': password,
      'fcm_token': fcmToken,
      'device_id': deviceId,
      'gender': gender,
      if (referCode != null && referCode.isNotEmpty) 'referer': referCode,
    };
    final response = await _client.postForm(
      ApiConstants.postUserRegister,
      data: bodyData,
    );

    _checkSuccess(response.data);

    final data = UserResponse.fromJson(response.data);
    final result = data.result?.first;
    if (result == null) throw Exception('User data not found in response');
    return result;
  }

  @override
  Future<UserModel> getProfile(String userId) async {
    final response = await _client.get(
      ApiConstants.getProfile,
      queryParams: {
        'purchase_key': AppConstants.purchaseKey,
        'userId': userId,
      },
    );
    _checkSuccess(response.data);
    final data = UserResponse.fromJson(response.data);
    return data.result!.first;
  }

  @override
  Future<UserModel> updateProfile(String userId, Map<String, dynamic> data) async {
    final response = await _client.postForm(
      ApiConstants.updateProfile,
      data: {
        'purchase_key': AppConstants.purchaseKey,
        'userId': userId,
        ...data,
      },
    );
    _checkSuccess(response.data);
    final resData = UserResponse.fromJson(response.data);
    return resData.result!.first;
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
    _checkSuccess(response.data);
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
    _checkSuccess(response.data);
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
    _checkSuccess(response.data);
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
      data: {
        'purchase_key': AppConstants.purchaseKey,
        'mobile': mobile,
        'password': password,
      },
    );
    _checkSuccess(response.data);
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
      data: {
        'purchase_key': AppConstants.purchaseKey,
        'id': userId,
        'fcm_token': fcmToken,
      },
    );
    _checkSuccess(response.data);
    final data = UserResponse.fromJson(response.data);
    return data.result!.first;
  }
}
