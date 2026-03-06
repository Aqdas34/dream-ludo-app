import 'package:equatable/equatable.dart';

enum OnlineGameStatus { waiting, playing, finished, error }

class OnlineLudoPlayer extends Equatable {
  final String userId;
  final String username;
  final String color; // RED, GREEN, YELLOW, BLUE
  final List<int> pieces; // positions 0..57
  final bool isReady;

  const OnlineLudoPlayer({
    required this.userId,
    required this.username,
    required this.color,
    required this.pieces,
    required this.isReady,
  });

  factory OnlineLudoPlayer.fromJson(Map<String, dynamic> json) {
    return OnlineLudoPlayer(
      userId: json['userId']?.toString() ?? '',
      username: json['username'] ?? '',
      color: json['color'] ?? 'RED',
      pieces: List<int>.from(json['pieces'] ?? [0, 0, 0, 0]),
      isReady: json['isReady'] ?? false,
    );
  }

  @override
  List<Object?> get props => [userId, username, color, pieces, isReady];
}

class OnlineChatMessage extends Equatable {
  final String userId;
  final String username;
  final String message;
  final int timestamp;

  const OnlineChatMessage({
    required this.userId,
    required this.username,
    required this.message,
    required this.timestamp,
  });

  factory OnlineChatMessage.fromJson(Map<String, dynamic> json) {
    return OnlineChatMessage(
      userId: json['userId']?.toString() ?? '',
      username: json['username'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [userId, username, message, timestamp];
}

class OnlineLudoState extends Equatable {
  final String roomId;
  final List<OnlineLudoPlayer> players;
  final OnlineGameStatus status;
  final int turn;
  final int diceValue;
  final List<OnlineChatMessage> messages;
  final bool isRolling;
  final bool hasRolled;
  final int totalPlayerCount;
  final String? winner;
  final String? errorMessage;

  const OnlineLudoState({
    this.roomId = '',
    this.players = const [],
    this.status = OnlineGameStatus.waiting,
    this.totalPlayerCount = 4,
    this.turn = 0,
    this.diceValue = 1,
    this.messages = const [],
    this.isRolling = false,
    this.hasRolled = false,
    this.winner,
    this.errorMessage,
  });

  factory OnlineLudoState.fromJson(Map<String, dynamic> json) {
    return OnlineLudoState(
      roomId: json['roomId'] ?? '',
      players: (json['players'] as List? ?? [])
          .map((p) => OnlineLudoPlayer.fromJson(p))
          .toList(),
      status: _parseStatus(json['status']),
      turn: json['turn'] ?? 0,
      diceValue: json['diceValue'] ?? 1,
      messages: (json['messages'] as List? ?? [])
          .map((m) => OnlineChatMessage.fromJson(m))
          .toList(),
      isRolling: json['isRolling'] ?? false,
      hasRolled: json['hasRolled'] ?? false,
      totalPlayerCount: json['totalPlayerCount'] ?? 4,
      winner: json['winner']?.toString(),
    );
  }

  static OnlineGameStatus _parseStatus(String? status) {
    switch (status) {
      case 'WAITING': return OnlineGameStatus.waiting;
      case 'PLAYING': return OnlineGameStatus.playing;
      case 'FINISHED': return OnlineGameStatus.finished;
      default: return OnlineGameStatus.waiting;
    }
  }

  OnlineLudoState copyWith({
    String? roomId,
    List<OnlineLudoPlayer>? players,
    OnlineGameStatus? status,
    int? turn,
    int? diceValue,
    List<OnlineChatMessage>? messages,
    bool? isRolling,
    bool? hasRolled,
    int? totalPlayerCount,
    String? winner,
    String? errorMessage,
  }) {
    return OnlineLudoState(
      roomId: roomId ?? this.roomId,
      players: players ?? this.players,
      status: status ?? this.status,
      turn: turn ?? this.turn,
      diceValue: diceValue ?? this.diceValue,
      messages: messages ?? this.messages,
      isRolling: isRolling ?? this.isRolling,
      hasRolled: hasRolled ?? this.hasRolled,
      totalPlayerCount: totalPlayerCount ?? this.totalPlayerCount,
      winner: winner ?? this.winner,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        roomId,
        players,
        status,
        turn,
        diceValue,
        messages,
        isRolling,
        hasRolled,
        totalPlayerCount,
        winner,
        errorMessage
      ];
}
