// ───────────────────────────────────────────────────────────────
// storage_service.dart  –  Secure local storage
// Replaces: Java → Preferences.java (SharedPreferences)
// Uses: flutter_secure_storage for JWT tokens
//        shared_preferences for non-sensitive data
// ───────────────────────────────────────────────────────────────

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageKeys {
  StorageKeys._();

  // Secure (encrypted)
  static const String accessToken = 'ACCESS_TOKEN';
  static const String userId = 'USER_ID';
  static const String password = 'PASSWORD'; // hashed only

  // Non-sensitive
  static const String fullName = 'KEY_FULL_NAME';
  static const String username = 'KEY_USERNAME';
  static const String email = 'KEY_EMAIL';
  static const String profilePhoto = 'KEY_PROFILE_PHOTO';
  static const String countryCode = 'KEY_COUNTRY_CODE';
  static const String mobile = 'KEY_MOBILE';
  static const String whatsapp = 'KEY_WHATSAPP';
  static const String referCode = 'KEY_REFER_CODE';
  static const String isAutoLogin = 'KEY_IS_AUTO_LOGIN';
  static const String notificationEnabled = 'NOTIFICATION_ENABLED';
  static const String fcmToken = 'FCM_TOKEN';
}

class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  StorageService(this._secureStorage, this._prefs);

  // ── Secure Token Methods ──────────────────────────────────────

  Future<void> saveToken(String token) async =>
      _secureStorage.write(key: StorageKeys.accessToken, value: token);

  Future<String?> getToken() async =>
      _secureStorage.read(key: StorageKeys.accessToken);

  Future<void> deleteToken() async =>
      _secureStorage.delete(key: StorageKeys.accessToken);

  Future<void> saveUserId(String id) async =>
      _secureStorage.write(key: StorageKeys.userId, value: id);

  Future<String?> getUserId() async =>
      _secureStorage.read(key: StorageKeys.userId);

  // ── Auth State ────────────────────────────────────────────────

  Future<bool> isLoggedIn() async {
    final autoLogin = _prefs.getString(StorageKeys.isAutoLogin);
    final userId = await getUserId();
    return autoLogin == '1' && userId != null && userId.isNotEmpty;
  }

  // ── Non-Sensitive String Getters/Setters ──────────────────────

  String getString(String key) => _prefs.getString(key) ?? '';

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  // ── User Profile Helpers ──────────────────────────────────────

  Future<void> saveUserProfile({
    required String userId,
    required String fullName,
    required String profilePhoto,
    required String username,
    required String email,
    required String countryCode,
    required String mobile,
    required String whatsapp,
    required String password,
  }) async {
    await saveUserId(userId);
    await _prefs.setString(StorageKeys.fullName, fullName);
    await _prefs.setString(StorageKeys.profilePhoto, profilePhoto);
    await _prefs.setString(StorageKeys.username, username);
    await _prefs.setString(StorageKeys.email, email);
    await _prefs.setString(StorageKeys.countryCode, countryCode);
    await _prefs.setString(StorageKeys.mobile, mobile);
    await _prefs.setString(StorageKeys.whatsapp, whatsapp);
    await _prefs.setString(StorageKeys.isAutoLogin, '1');
    await _secureStorage.write(key: StorageKeys.password, value: password);
  }

  Future<void> saveFcmToken(String token) =>
      _prefs.setString(StorageKeys.fcmToken, token);

  String get fcmToken => _prefs.getString(StorageKeys.fcmToken) ?? '';

  // ── Logout ────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }

  // ── Notification ──────────────────────────────────────────────

  bool get isNotificationEnabled =>
      _prefs.getBool(StorageKeys.notificationEnabled) ?? true;

  Future<void> setNotificationEnabled(bool value) =>
      _prefs.setBool(StorageKeys.notificationEnabled, value);
}
