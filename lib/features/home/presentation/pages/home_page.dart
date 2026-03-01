// ── home_page.dart  –  Main dashboard with bottom nav ──────────
// Mirrors: Java → MainActivity.java + Fragment tabs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_ludo/core/di/service_locator.dart';
import 'package:dream_ludo/core/router/app_router.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/match/domain/usecases/get_matches_usecase.dart';
import 'package:dream_ludo/features/match/presentation/bloc/match_bloc.dart';
import 'package:dream_ludo/features/match/presentation/widgets/matches_tab_view.dart';
import 'package:dream_ludo/core/services/storage_service.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:dream_ludo/core/constants/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0;
  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: IndexedStack(
          index: _bottomNavIndex,
          children: const [
            _MatchesTab(),
            _HowToPlayTab(),
            _SettingsTab(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      titleSpacing: 5,
      title: Row(
        children: [
          Image.asset(
            'assets/images/app_icon.png',
            width: 35,
            height: 35,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.casino_rounded,
              color: AppColors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'DreamLudo',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.white),
              onPressed: () => context.push(AppRoutes.notification),
            ),
            // Badge placeholder
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      currentIndex: _bottomNavIndex,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      onTap: (i) => setState(() => _bottomNavIndex = i),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_esports_outlined),
          activeIcon: Icon(Icons.sports_esports),
          label: 'Game',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.help_outline_rounded),
          activeIcon: Icon(Icons.help_rounded),
          label: 'How To Play?',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz_rounded),
          activeIcon: Icon(Icons.more_horiz_rounded),
          label: 'More',
        ),
      ],
    );
  }

  void _handleBackPress() {
    final now = DateTime.now();
    if (_lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
    } else {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press BACK again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ── Tab: Matches ─────────────────────────────────────────────────

class _MatchesTab extends StatelessWidget {
  const _MatchesTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MatchBloc>()
        ..add(const LoadMatches(MatchTab.upcoming))
        ..subscribeToMatchUpdates(),
      child: const MatchesTabView(),
    );
  }
}

// ── Tab: How To Play? (Webview/URL) ───────────────────────────────

class _HowToPlayTab extends StatelessWidget {
  const _HowToPlayTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.help_center_outlined, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('How To Play?', style: AppTextStyles.heading2),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Learn how to play DreamLudo and win big!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => launchUrl(Uri.parse(AppConstants.howToPlay)),
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            child: const Text('Open Knowledge Base'),
          ),
        ],
      ),
    );
  }
}

// ── Tab: Settings / More ──────────────────────────────────────────

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    final storage = sl<StorageService>();
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Header Background (Red curve)
          Stack(
            children: [
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                child: Row(
                  children: [
                    // Profile Circle
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        storage.getString(StorageKeys.fullName).isNotEmpty
                            ? storage.getString(StorageKeys.fullName)[0].toUpperCase()
                            : 'D',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storage.getString(StorageKeys.fullName).isNotEmpty
                              ? storage.getString(StorageKeys.fullName)
                              : 'Dream Player',
                          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
                        ),
                        Text(
                          '+${storage.getString(StorageKeys.countryCode)} ${storage.getString(StorageKeys.mobile)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Wallet Card (CardView in Kotlin)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: AppColors.white,
              elevation: 4,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My Balance', 
                          style: TextStyle(color: AppColors.grey60, fontSize: 16)),
                        Text('${AppConstants.currencySign} 0.00', 
                          style: AppTextStyles.heading2.copyWith(color: AppColors.grey80)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _WalletAction(
                          label: 'Deposit Cash',
                          amount: '${AppConstants.currencySign}0.00',
                          icon: Icons.add_circle_outline_rounded,
                          color: AppColors.fabDeposit,
                          onTap: () => context.push(AppRoutes.deposit),
                        ),
                        _WalletAction(
                          label: 'Withdraw Cash',
                          amount: '${AppConstants.currencySign}0.00',
                          icon: Icons.remove_circle_outline_rounded,
                          color: AppColors.fabWithdraw,
                          onTap: () => context.push(AppRoutes.withdraw),
                        ),
                        _WalletAction(
                          label: 'Bonus Cash',
                          amount: '${AppConstants.currencySign}0.00',
                          icon: Icons.stars_rounded,
                          color: AppColors.fabBonus,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1,
              children: [
                _GridItem(icon: Icons.person_outline_rounded, label: 'Profile', onTap: () => context.push(AppRoutes.profile)),
                _GridItem(icon: Icons.history_rounded, label: 'History', onTap: () => context.push(AppRoutes.history)),
                _GridItem(icon: Icons.bar_chart_rounded, label: 'Statistics', onTap: () => context.push(AppRoutes.statistics)),
                _GridItem(icon: Icons.notifications_none_rounded, label: 'Notification', onTap: () => context.push(AppRoutes.notification)),
                _GridItem(icon: Icons.share_rounded, label: 'Refer', onTap: () => context.push(AppRoutes.referral)),
                _GridItem(icon: Icons.leaderboard_rounded, label: 'Leaderboard', onTap: () {}),
                _GridItem(icon: Icons.policy_outlined, label: 'Privacy Policy', 
                  onTap: () => launchUrl(Uri.parse('https://dreamludo.page.link/privacy')),
                ),
                _GridItem(icon: Icons.help_outline_rounded, label: 'FAQ', onTap: () {}),
                _GridItem(
                  icon: Icons.support_agent_rounded, 
                  label: 'Need Help', 
                  onTap: () => launchUrl(Uri.parse('mailto:${AppConstants.supportEmail}')),
                ),
                _GridItem(icon: Icons.info_outline_rounded, label: 'About Us', onTap: () {}),
                _GridItem(icon: Icons.description_outlined, label: 'Terms', onTap: () {}),
                _GridItem(
                  icon: Icons.logout_rounded, 
                  label: 'Logout', 
                  onTap: () => _showLogoutDialog(context),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('LOGOUT ACCOUNT'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await sl<StorageService>().clearAll();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            }, 
            child: const Text('Confirm')
          ),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WalletAction({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.grey80)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey60)),
        ],
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _GridItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color ?? AppColors.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
