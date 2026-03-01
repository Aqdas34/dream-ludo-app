// ───────────────────────────────────────────────────────────────
// match_model.dart  –  Match entity
// Manual fromJson — safe for Spring Boot APIs (strings/nums mixed)
// ───────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

// Safe parsers shared across models
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

class MatchModel extends Equatable {
  final String? id;
  final double? matchFee;
  final double? prize;
  final int?    tableSize;
  final int?    type;
  final String? playTime;
  final String? currentTime;
  final String? startTime;
  final int?    isJoined;
  final int?    win;
  final int?    tableJoined;
  final String? resultStatus;
  final String? parti1Id;
  final String? parti2Id;
  final String? parti1Name;
  final String? parti2Name;
  final String? parti1Status;
  final String? parti2Status;
  final String? whatsappNo1;
  final String? whatsappNo2;
  final String? winnerName;

  const MatchModel({
    this.id,
    this.matchFee,
    this.prize,
    this.tableSize,
    this.type,
    this.playTime,
    this.currentTime,
    this.startTime,
    this.isJoined,
    this.win,
    this.tableJoined,
    this.resultStatus,
    this.parti1Id,
    this.parti2Id,
    this.parti1Name,
    this.parti2Name,
    this.parti1Status,
    this.parti2Status,
    this.whatsappNo1,
    this.whatsappNo2,
    this.winnerName,
  });

  bool get hasJoined => isJoined == 1;
  bool get isOpen    => (tableJoined ?? 0) < (tableSize ?? 2);
  int  get spotsLeft => (tableSize ?? 2) - (tableJoined ?? 0);

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id:           _str(json['id']),
      matchFee:     _toDouble(json['match_fee']),
      prize:        _toDouble(json['prize']),
      tableSize:    _toInt(json['table_size']),
      type:         _toInt(json['type']),
      playTime:     _str(json['play_time']),
      currentTime:  _str(json['current_time']),
      startTime:    _str(json['start_time']),
      isJoined:     _toInt(json['is_joined']),
      win:          _toInt(json['win']),
      tableJoined:  _toInt(json['table_joined']),
      resultStatus: _str(json['result_status']),
      parti1Id:     _str(json['parti1_id']),
      parti2Id:     _str(json['parti2_id']),
      parti1Name:   _str(json['parti1_name']),
      parti2Name:   _str(json['parti2_name']),
      parti1Status: _str(json['parti1_status']),
      parti2Status: _str(json['parti2_status']),
      whatsappNo1:  _str(json['whatsapp_no1']),
      whatsappNo2:  _str(json['whatsapp_no2']),
      winnerName:   _str(json['winner_name']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'match_fee':     matchFee,
    'prize':         prize,
    'table_size':    tableSize,
    'type':          type,
    'play_time':     playTime,
    'current_time':  currentTime,
    'start_time':    startTime,
    'is_joined':     isJoined,
    'win':           win,
    'table_joined':  tableJoined,
    'result_status': resultStatus,
    'parti1_id':     parti1Id,
    'parti2_id':     parti2Id,
    'parti1_name':   parti1Name,
    'parti2_name':   parti2Name,
    'parti1_status': parti1Status,
    'parti2_status': parti2Status,
    'whatsapp_no1':  whatsappNo1,
    'whatsapp_no2':  whatsappNo2,
    'winner_name':   winnerName,
  };

  @override
  List<Object?> get props => [id];
}

class MatchResponse {
  final List<MatchModel>? result;
  const MatchResponse({this.result});

  factory MatchResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['result'];
    List<MatchModel>? list;
    if (raw is List) {
      list = raw
          .whereType<Map<String, dynamic>>()
          .map(MatchModel.fromJson)
          .toList();
    }
    return MatchResponse(result: list);
  }
}
