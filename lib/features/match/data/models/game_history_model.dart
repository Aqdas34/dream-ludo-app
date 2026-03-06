import 'package:equatable/equatable.dart';

class GameHistoryModel extends Equatable {
  final int id;
  final String roomId;
  final String userId;
  final List<HistoryPlayer> players;
  final String? winnerId;
  final String? winnerName;
  final String status;
  final int gemsAwarded;
  final DateTime createdAt;

  const GameHistoryModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.players,
    this.winnerId,
    this.winnerName,
    required this.status,
    required this.gemsAwarded,
    required this.createdAt,
  });

  factory GameHistoryModel.fromJson(Map<String, dynamic> json) {
    return GameHistoryModel(
      id: json['id'] ?? 0,
      roomId: json['roomId'] ?? '',
      userId: json['userId'] ?? '',
      players: (json['players'] as List? ?? []).map((p) => HistoryPlayer.fromJson(p)).toList(),
      winnerId: json['winnerId'],
      winnerName: json['winnerName'],
      status: json['status'] ?? 'ONGOING',
      gemsAwarded: json['gemsAwarded'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, roomId, status];
}

class HistoryPlayer extends Equatable {
  final String userId;
  final String username;
  final String color;

  const HistoryPlayer({
    required this.userId,
    required this.username,
    required this.color,
  });

  factory HistoryPlayer.fromJson(Map<String, dynamic> json) {
    return HistoryPlayer(
      userId: json['userId']?.toString() ?? '',
      username: json['username'] ?? '',
      color: json['color'] ?? 'RED',
    );
  }

  @override
  List<Object?> get props => [userId, username, color];
}
