import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import '../bloc/rewards_bloc.dart';
import '../bloc/rewards_event.dart';
import '../bloc/rewards_state.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<RewardsBloc, RewardsState>(
        builder: (context, state) {
          if (state is RewardsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RewardsLoaded) {
            return _buildContent(context, state);
          }
          if (state is RewardsError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, RewardsLoaded state) {
    return CustomScrollView(
      slivers: [
        // ── Header Section ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFF1A237E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.diamond_rounded, color: Colors.white, size: 60),
                const SizedBox(height: 12),
                const Text(
                  'REWARDS HUB',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBalanceCard('GEMS', '${state.reward.gems}', Icons.diamond_rounded, AppColors.gold, () => context.push(AppRoutes.store)),
                    _buildBalanceCard('XP', '1,250', Icons.bolt_rounded, Colors.blue, () {}),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Main Actions Section ─────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text('GAMING REWARDS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              const SizedBox(height: 16),
              
              _buildFeatureCard(
                context,
                title: 'Daily Rewards',
                subtitle: 'Claim your daily bonus gems',
                icon: Icons.calendar_today_rounded,
                color: Colors.orange,
                onTap: () => context.push(AppRoutes.dailyReward),
              ),
              const SizedBox(height: 16),

              _buildFeatureCard(
                 context,
                 title: 'Achievements',
                 subtitle: 'Unlock badges and earn big',
                 icon: Icons.emoji_events_rounded,
                 color: AppColors.gold,
                 onTap: () => context.push(AppRoutes.achievements),
              ),
              const SizedBox(height: 16),

              _buildFeatureCard(
                 context,
                 title: 'Gem Store',
                 subtitle: 'Get more gems for premium items',
                 icon: Icons.store_rounded,
                 color: Colors.cyan,
                 onTap: () => context.push(AppRoutes.store),
              ),

              const SizedBox(height: 32),
              const Text('TRANSACTION HISTORY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              const SizedBox(height: 16),
            ]),
          ),
        ),

        // ── History List ─────────────────────────────────────────────
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = state.reward.history[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: (item.amount > 0 ? AppColors.success : AppColors.error).withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(item.amount > 0 ? Icons.add_rounded : Icons.remove_rounded, color: item.amount > 0 ? AppColors.success : AppColors.error, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.description, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(item.type, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(
                      '${item.amount > 0 ? "+" : ""}${item.amount}',
                      style: TextStyle(color: item.amount > 0 ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
            childCount: state.reward.history.length,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }

  Widget _buildBalanceCard(String label, String value, IconData icon, Color color, VoidCallback onTap) {
     return GestureDetector(
        onTap: onTap,
        child: Container(
           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
           decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
           ),
           child: Column(
              children: [
                 Icon(icon, color: color, size: 24),
                 const SizedBox(height: 8),
                 Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                 Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
           ),
        ),
     );
  }

  Widget _buildFeatureCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.gold, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
