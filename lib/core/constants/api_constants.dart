// ───────────────────────────────────────────────────────────────
// api_constants.dart  –  All API endpoint paths
// Mirrors: Java → ApiConstant.java
// ───────────────────────────────────────────────────────────────

class ApiConstants {
  ApiConstants._();

  // Auth
  static const String postUserRegister = 'api/post_user_register';
  static const String getUserLogin = 'api/get_user_login';
  static const String getUserProfile = 'api/get_user_profile';
  static const String getAppDetails = 'api/get_app_details';
  static const String getProfile = 'api/get_profile';
  static const String updateProfile = 'api/update_profile';

  // Profile
  static const String updateUserProfile = 'api/update_user_profile';
  static const String updateUserPhoto = 'api/update_user_photo';
  static const String resetPassword = 'api/reset_password';

  // Verification
  static const String verifyRefer = 'api/verify_refer';
  static const String verifyMobile = 'api/verify_mobile';
  static const String verifyRegister = 'api/verify_register';

  // Matches
  static const String getMatchUpcoming = 'api/get_match_upcoming';
  static const String getMatchOngoing = 'api/get_match_ongoing';
  static const String getMatchCompleted = 'api/get_match_completed';
  static const String postJoinMatch = 'api/post_join_match';
  static const String postResult = 'api/post_result';
  static const String deleteParticipant = 'api/delete_participant';
  static const String searchParticipant = 'api/search_participant';

  // Wallet
  static const String postDeposit = 'api/post_deposit';
  static const String postWithdraw = 'api/post_withdraw';
  static const String postBalance = 'api/post_balance';

  // Leaderboard & Stats
  static const String getLeaderboard = 'api/get_leaderboard';
  static const String getHistory = 'api/get_history';
  static const String getStatistics = 'api/get_statistics';
  static const String getNotification = 'api/get_notification';

  // Static pages
  static const String getPrivacyPolicy = 'api/get_privacy_policy';
  static const String getTermsCondition = 'api/get_terms_condition';
  static const String getLegalPolicy = 'api/get_legal_policy';
  static const String getAboutUs = 'api/get_about_us';
  static const String getFaq = 'api/get_faq';
  static const String getRules = 'api/get_rules';
}
