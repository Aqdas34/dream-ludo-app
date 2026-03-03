class RewardModel {
  final int coins;
  final int gems;
  final int totalWins;
  final int totalGames;
  final DateTime? lastDailyClaim;
  final List<RewardHistoryItem> history;

  RewardModel({
    required this.coins,
    required this.gems,
    required this.totalWins,
    required this.totalGames,
    this.lastDailyClaim,
    this.history = const [],
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      coins: json['coins'] ?? 0,
      gems: json['gems'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
      totalGames: json['totalGames'] ?? 0,
      lastDailyClaim: json['lastDailyClaim'] != null 
          ? DateTime.parse(json['lastDailyClaim']) 
          : null,
      history: (json['history'] as List? ?? [])
          .map((e) => RewardHistoryItem.fromJson(e))
          .toList(),
    );
  }
}

class RewardHistoryItem {
  final int amount;
  final String type;
  final String description;
  final DateTime createdAt;

  RewardHistoryItem({
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory RewardHistoryItem.fromJson(Map<String, dynamic> json) {
    return RewardHistoryItem(
      amount: json['amount'] ?? 0,
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
