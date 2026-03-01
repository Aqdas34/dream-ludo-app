// ───────────────────────────────────────────────────────────────
// app_constants.dart  –  Global app-level constants
// ───────────────────────────────────────────────────────────────

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'DreamLudo';
  static const String purchaseKey = '111111111111';

  // FCM
  static const String topicGlobal = 'Global';

  // Currency (updated at runtime from /api/get_app_details)
  static String countryCode = '+91';
  static String currencyCode = 'INR';
  static String currencySign = '₹';

  // Payment gateway modes
  static const int paymentPaytm = 0;
  static const int paymentPayu = 1;
  static const int paymentRazorpay = 2;

  // Game settings (updated at runtime)
  static String gameName = 'Ludo King';
  static String packageName = 'com.ludo.king';
  static String supportEmail = 'support@dreamludo.com';
  static String supportMobile = '0000000000';
  static String howToPlay = 'https://google.com';

  // Wallet limits (updated at runtime)
  static int minJoinLimit = 100;
  static int referralPercentage = 1;
  static int minWithdrawLimit = 100;
  static int maxWithdrawLimit = 5000;
  static int minDepositLimit = 50;
  static int maxDepositLimit = 5000;

  // Modes (updated at runtime)
  static int maintenanceMode = 0;
  static int walletMode = 0;
  static int modeOfPayment = 0;

  // Payment IDs (updated at runtime)
  static String paytmMId = '';
  static String payuMId = '';
  static String payuMKey = '';
  static String updateUrl = '';
}
