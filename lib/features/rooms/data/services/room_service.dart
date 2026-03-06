import 'package:dream_ludo/core/config/env.dart';
import 'package:dio/dio.dart';

class RoomService {
  final Dio _dio = Dio(BaseOptions(baseUrl: Env.baseUrl));

  Future<Map<String, dynamic>?> createRoom({
    required int playerCount,
    required bool isPrivate,
    required double entryFee,
  }) async {
    try {
      // Mocking for now as per user instruction to focus on local/direct play
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'roomId': 'LUDO${DateTime.now().millisecond}',
        'playerCount': playerCount,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> joinRoom(String roomId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'success': true,
        'roomId': roomId,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
