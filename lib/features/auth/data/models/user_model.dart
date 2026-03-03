// ───────────────────────────────────────────────────────────────
// user_model.dart  –  User entity
// Uses safe type parsing — Spring Boot often sends numbers as strings
// ───────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

// Safe parsers — handle both "1.5" (String) and 1.5 (num) from API
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

class UserModel extends Equatable {
  final String? id;
  final String? fullName;
  final String? profileImg;
  final String? username;
  final String? email;
  final String? countryCode;
  final String? mobile;
  final String? whatsappNo;
  final double? depositBal;
  final double? wonBal;
  final double? bonusBal;
  final String? fcmToken;
  final int? isActive;
  final int? isBlock;
  final String? msg;
  final int? success;
  final String? token;

  const UserModel({
    this.id,
    this.fullName,
    this.profileImg,
    this.username,
    this.email,
    this.countryCode,
    this.mobile,
    this.whatsappNo,
    this.depositBal,
    this.wonBal,
    this.bonusBal,
    this.fcmToken,
    this.isActive,
    this.isBlock,
    this.msg,
    this.success,
    this.token,
  });

  double get totalBalance =>
      (depositBal ?? 0) + (wonBal ?? 0) + (bonusBal ?? 0);

  bool get isBlocked  => isBlock == 1;
  bool get isVerified => isActive == 1;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:          _str(json['id']),
      fullName:    _str(json['full_name']),
      profileImg:  _str(json['profile_img']),
      username:    _str(json['username']),
      email:       _str(json['email']),
      countryCode: _str(json['country_code']),
      mobile:      _str(json['mobile']),
      whatsappNo:  _str(json['whatsapp_no']),
      depositBal:  _toDouble(json['deposit_bal']),
      wonBal:      _toDouble(json['won_bal']),
      bonusBal:    _toDouble(json['bonus_bal']),
      fcmToken:    _str(json['fcm_token']),
      isActive:    _toInt(json['is_active']),
      isBlock:     _toInt(json['is_block']),
      msg:         _str(json['msg']),
      success:     _toInt(json['success']),
      token:       _str(json['token']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':          id,
    'full_name':   fullName,
    'profile_img': profileImg,
    'username':    username,
    'email':       email,
    'country_code': countryCode,
    'mobile':      mobile,
    'whatsapp_no': whatsappNo,
    'deposit_bal': depositBal,
    'won_bal':     wonBal,
    'bonus_bal':   bonusBal,
    'fcm_token':   fcmToken,
    'is_active':   isActive,
    'is_block':    isBlock,
    'msg':         msg,
    'success':     success,
    'token':       token,
  };

  @override
  List<Object?> get props => [id, email, username, token];
}

class UserResponse {
  final List<UserModel>? result;
  const UserResponse({this.result});

  factory UserResponse.fromJson(dynamic json) {
    // Shape 1: raw list  →  [ {...}, {...} ]
    if (json is List) {
      return UserResponse(
        result: json
            .where((e) => e is Map)
            .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    }

    if (json is Map) {
      final raw = json['result'];

      // Shape 2: { "result": [ {...} ] }
      if (raw is List) {
        return UserResponse(
          result: raw
              .where((e) => e is Map)
              .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(),
        );
      }

      // Shape 3: { "result": { ... } }  (single object)
      if (raw is Map) {
        return UserResponse(result: [UserModel.fromJson(Map<String, dynamic>.from(raw))]);
      }

      // Shape 4: the map itself IS the user object
      if (json.containsKey('id') || json.containsKey('username')) {
        return UserResponse(result: [UserModel.fromJson(Map<String, dynamic>.from(json))]);
      }
    }

    return const UserResponse(result: null);
  }
}

