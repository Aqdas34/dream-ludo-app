// ───────────────────────────────────────────────────────────────
// app_model.dart  –  App config from /api/get_user_login response
// Manual fromJson — safe for Spring Boot APIs that send ints as strings
// ───────────────────────────────────────────────────────────────

// Safe parsers
double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

String? _str(dynamic v) => v?.toString();

class AppModel {
  final String? purchaseKey;
  final String? countryCode;
  final String? currencyCode;
  final String? currencySign;
  final String? paytmMerId;
  final String? payuId;
  final String? payuKey;
  final int?    minEntryFee;
  final int?    referPercentage;
  final int?    maintenanceMode;
  final int?    mop;
  final int?    walletMode;
  final int?    minWithdraw;
  final int?    maxWithdraw;
  final int?    minDeposit;
  final int?    maxDeposit;
  final String? gameName;
  final String? packageName;
  final String? howToPlay;
  final String? cusSupportEmail;
  final String? cusSupportMobile;
  final String? forceUpdate;
  final String? whatsNew;
  final String? updateDate;
  final String? latestVersionName;
  final String? latestVersionCode;
  final String? updateUrl;
  final int?    success;
  final String? msg;

  const AppModel({
    this.purchaseKey,
    this.countryCode,
    this.currencyCode,
    this.currencySign,
    this.paytmMerId,
    this.payuId,
    this.payuKey,
    this.minEntryFee,
    this.referPercentage,
    this.maintenanceMode,
    this.mop,
    this.walletMode,
    this.minWithdraw,
    this.maxWithdraw,
    this.minDeposit,
    this.maxDeposit,
    this.gameName,
    this.packageName,
    this.howToPlay,
    this.cusSupportEmail,
    this.cusSupportMobile,
    this.forceUpdate,
    this.whatsNew,
    this.updateDate,
    this.latestVersionName,
    this.latestVersionCode,
    this.updateUrl,
    this.success,
    this.msg,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      purchaseKey:      _str(json['purchase_key']),
      countryCode:      _str(json['country_code']),
      currencyCode:     _str(json['currency_code']),
      currencySign:     _str(json['currency_sign']),
      paytmMerId:       _str(json['paytm_mer_id']),
      payuId:           _str(json['payu_id']),
      payuKey:          _str(json['payu_key']),
      minEntryFee:      _toInt(json['min_entry_fee']),
      referPercentage:  _toInt(json['refer_percentage']),
      maintenanceMode:  _toInt(json['maintenance_mode']),
      mop:              _toInt(json['mop']),
      walletMode:       _toInt(json['wallet_mode']),
      minWithdraw:      _toInt(json['min_withdraw']),
      maxWithdraw:      _toInt(json['max_withdraw']),
      minDeposit:       _toInt(json['min_deposit']),
      maxDeposit:       _toInt(json['max_deposit']),
      gameName:         _str(json['game_name']),
      packageName:      _str(json['package_name']),
      howToPlay:        _str(json['how_to_play']),
      cusSupportEmail:  _str(json['cus_support_email']),
      cusSupportMobile: _str(json['cus_support_mobile']),
      forceUpdate:      _str(json['force_update']),
      whatsNew:         _str(json['whats_new']),
      updateDate:       _str(json['update_date']),
      latestVersionName:_str(json['latest_version_name']),
      latestVersionCode:_str(json['latest_version_code']),
      updateUrl:        _str(json['update_url']),
      success:          _toInt(json['success']),
      msg:              _str(json['msg']),
    );
  }
}

class AppResponse {
  final List<AppModel>? result;
  const AppResponse({this.result});

  factory AppResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['result'];
    List<AppModel>? list;
    if (raw is List) {
      list = raw
          .whereType<Map<String, dynamic>>()
          .map(AppModel.fromJson)
          .toList();
    }
    return AppResponse(result: list);
  }
}
