class GemPackage {
  final String id;
  final String name;
  final int gemsAmount;
  final int bonusGems;
  final double price;
  final String currency;
  final bool isPopular;

  GemPackage({
    required this.id,
    required this.name,
    required this.gemsAmount,
    required this.bonusGems,
    required this.price,
    required this.currency,
    this.isPopular = false,
  });

  factory GemPackage.fromJson(Map<String, dynamic> json) {
    return GemPackage(
      id: json['id'],
      name: json['name'],
      gemsAmount: json['gems_amount'],
      bonusGems: json['bonus_gems'] ?? 0,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      isPopular: json['is_popular'] ?? false,
    );
  }
}

class Achievement {
  final String id;
  final String key;
  final String name;
  final String description;
  final int rewardGems;
  final int rewardXP;
  final int currentProgress;
  final int maxProgress;
  final bool isCompleted;

  Achievement({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.rewardGems,
    required this.rewardXP,
    required this.currentProgress,
    required this.maxProgress,
    required this.isCompleted,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      key: json['achievement_key'],
      name: json['name'],
      description: json['description'],
      rewardGems: json['reward_gems'],
      rewardXP: json['reward_xp'],
      currentProgress: json['current_progress'] ?? 0,
      maxProgress: json['max_progress'],
      isCompleted: json['is_completed'] ?? false,
    );
  }
}
