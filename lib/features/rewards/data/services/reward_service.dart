import 'package:dio/dio.dart';
import 'package:dream_ludo/core/config/env.dart';
import 'package:dream_ludo/features/rewards/data/models/reward_models.dart';

class RewardService {
  final Dio _dio = Dio(BaseOptions(baseUrl: Env.apiUrl));

  Future<int> getGemBalance(String userId) async {
    try {
      final response = await _dio.get('/rewards/gems/balance/$userId');
      if (response.data['success']) {
        return response.data['balance'] as int;
      }
      return 0;
    } catch (e) {
      print('❌ Error fetching gem balance: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> claimDailyReward(String userId) async {
    try {
      final response = await _dio.post('/rewards/gems/claim-daily', data: {'userId': userId});
      if (response.data['success']) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('❌ Error claiming daily reward: $e');
      return null;
    }
  }

  Future<bool> verifyPurchase(String userId, String packageId, String transactionId) async {
    try {
      final response = await _dio.post('/rewards/gems/verify-purchase', data: {
        'userId': userId,
        'packageId': packageId,
        'transactionId': transactionId,
      });
      return response.data['success'];
    } catch (e) {
      print('❌ Error verifying purchase: $e');
      return false;
    }
  }

  Future<List<Achievement>> getAchievements(String userId) async {
    try {
      final response = await _dio.get('/rewards/gems/achievements/$userId');
      if (response.data['success']) {
        final List list = response.data['achievements'];
        return list.map((item) => Achievement.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error fetching achievements: $e');
      return [];
    }
  }
}
