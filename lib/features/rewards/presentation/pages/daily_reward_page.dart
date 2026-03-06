import 'package:flutter/material.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';

class DailyRewardPage extends StatelessWidget {
  const DailyRewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DAILY REWARDS', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 80, color: AppColors.primary),
              const SizedBox(height: 32),
              const Text(
                '7-Day Login Streak',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Claim your daily gems to power up your game!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 48),
              
              // ── 7 Day Grid ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) => _buildDayItem(index + 1, index < 3)),
              ),

              const SizedBox(height: 64),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.5),
                ),
                child: const Text(
                  'CLAIM REWARD',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayItem(int day, bool isClaimed) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 54,
          decoration: BoxDecoration(
            color: isClaimed ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isClaimed ? AppColors.primary : Colors.white10, width: 2),
          ),
          child: Center(
            child: Icon(
              isClaimed ? Icons.check_circle_rounded : Icons.diamond_rounded,
              color: isClaimed ? Colors.white : AppColors.primary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('DAY $day', style: TextStyle(color: isClaimed ? Colors.white : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
