import 'package:flutter/material.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/rewards/data/models/reward_models.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy achievements
    final List<Achievement> achievements = [
      Achievement(id: '1', key: 'first_win', name: 'First Victory', description: 'Win your first game', rewardGems: 100, rewardXP: 50, currentProgress: 1, maxProgress: 1, isCompleted: true),
      Achievement(id: '2', key: 'capture_10', name: 'Hunter', description: 'Capture 10 opponent pieces', rewardGems: 250, rewardXP: 100, currentProgress: 4, maxProgress: 10, isCompleted: false),
      Achievement(id: '3', key: 'win_10', name: 'Pro Player', description: 'Win 10 games', rewardGems: 500, rewardXP: 250, currentProgress: 2, maxProgress: 10, isCompleted: false),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ACHIEVEMENTS', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) => _buildAchievementCard(achievements[index]),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    bool isCompleted = achievement.isCompleted;
    double progress = (achievement.currentProgress / achievement.maxProgress).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isCompleted ? AppColors.gold.withOpacity(0.5) : Colors.white10, width: 2),
      ),
      child: Row(
        children: [
          _buildBadge(achievement),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(achievement.description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? AppColors.gold : AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${achievement.currentProgress}/${achievement.maxProgress}', style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                    _buildRewardChip(achievement.rewardGems, achievement.rewardXP),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(Achievement ach) {
     return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
           color: ach.isCompleted ? AppColors.gold.withOpacity(0.1) : Colors.white10,
           shape: BoxShape.circle,
        ),
        child: Icon(
           ach.isCompleted ? Icons.emoji_events_rounded : Icons.lock_rounded,
           color: ach.isCompleted ? AppColors.gold : Colors.white24,
           size: 30,
        ),
     );
  }

  Widget _buildRewardChip(int gems, int xp) {
     return Row(
        children: [
           const Icon(Icons.diamond_rounded, color: AppColors.primary, size: 14),
           const SizedBox(width: 2),
           Text('$gems', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
           const SizedBox(width: 8),
           const Icon(Icons.bolt_rounded, color: Colors.amber, size: 14),
           const SizedBox(width: 2),
           Text('$xp XP', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
     );
  }
}
