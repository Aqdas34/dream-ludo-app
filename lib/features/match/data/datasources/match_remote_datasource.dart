// ───────────────────────────────────────────────────────────────
// match_remote_datasource.dart
// Fault-tolerant: handles both List and Map responses from API
// ───────────────────────────────────────────────────────────────

import 'package:dream_ludo/core/constants/api_constants.dart';
import 'package:dream_ludo/core/constants/app_constants.dart';
import 'package:dream_ludo/core/network/dio_client.dart';
import 'package:dream_ludo/features/match/data/models/match_model.dart';

abstract class MatchRemoteDataSource {
  Future<List<MatchModel>> getUpcoming(String userId);
  Future<List<MatchModel>> getOngoing(String userId);
  Future<List<MatchModel>> getCompleted(String userId);
  Future<MatchModel> joinMatch(String matchId, String userId);
  Future<MatchModel> leaveMatch(String matchId, String userId);
  Future<MatchModel> submitResult({
    required String matchId,
    required String userId,
    required String status,
    String? proofImage,
  });
}

class MatchRemoteDataSourceImpl implements MatchRemoteDataSource {
  final DioClient _client;
  MatchRemoteDataSourceImpl(this._client);

  /// Safely extracts a List<MatchModel> regardless of API response shape:
  ///   - Raw list:                  [ {...}, {...} ]
  ///   - Wrapped in 'result':       { "result": [ {...} ] }
  ///   - Single object in 'result': { "result": { ... } }
  List<MatchModel> _parseList(dynamic responseData) {
    if (responseData == null) return [];

    // Already a list
    if (responseData is List) {
      return responseData
          .whereType<Map<String, dynamic>>()
          .map(MatchModel.fromJson)
          .toList();
    }

    // Map with 'result' key
    if (responseData is Map<String, dynamic>) {
      final raw = responseData['result'];
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(MatchModel.fromJson)
            .toList();
      }
      if (raw is Map<String, dynamic>) {
        return [MatchModel.fromJson(raw)];
      }
    }

    return [];
  }

  MatchModel _parseSingle(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final raw = responseData['result'];
      if (raw is List && raw.isNotEmpty) {
        return MatchModel.fromJson(raw[0] as Map<String, dynamic>);
      }
      if (raw is Map<String, dynamic>) {
        return MatchModel.fromJson(raw);
      }
      // Maybe responseData itself is the match
      return MatchModel.fromJson(responseData);
    }
    throw Exception('Unexpected response format');
  }

  @override
  Future<List<MatchModel>> getUpcoming(String userId) async {
    final response = await _client.get(
      ApiConstants.getMatchUpcoming,
      queryParams: {
        'purchase_key': AppConstants.purchaseKey,
        'user_id': userId,
      },
    );
    return _parseList(response.data);
  }

  @override
  Future<List<MatchModel>> getOngoing(String userId) async {
    final response = await _client.get(
      ApiConstants.getMatchOngoing,
      queryParams: {
        'purchase_key': AppConstants.purchaseKey,
        'user_id': userId,
      },
    );
    return _parseList(response.data);
  }

  @override
  Future<List<MatchModel>> getCompleted(String userId) async {
    final response = await _client.get(
      ApiConstants.getMatchCompleted,
      queryParams: {
        'purchase_key': AppConstants.purchaseKey,
        'user_id': userId,
      },
    );
    return _parseList(response.data);
  }

  @override
  Future<MatchModel> joinMatch(String matchId, String userId) async {
    final response = await _client.postForm(
      ApiConstants.postJoinMatch,
      formData: {
        'purchase_key': AppConstants.purchaseKey,
        'match_id': matchId,
        'parti1': userId,
      },
    );
    return _parseSingle(response.data);
  }

  @override
  Future<MatchModel> leaveMatch(String matchId, String userId) async {
    final response = await _client.postForm(
      ApiConstants.deleteParticipant,
      formData: {
        'purchase_key': AppConstants.purchaseKey,
        'match_id': matchId,
        'parti1': userId,
      },
    );
    return _parseSingle(response.data);
  }

  @override
  Future<MatchModel> submitResult({
    required String matchId,
    required String userId,
    required String status,
    String? proofImage,
  }) async {
    final response = await _client.postForm(
      ApiConstants.postResult,
      formData: {
        'purchase_key': AppConstants.purchaseKey,
        'match_id': matchId,
        'user_id': userId,
        'parti1_status': status,
        if (proofImage != null) 'parti1_proof': proofImage,
      },
    );
    return _parseSingle(response.data);
  }
}
