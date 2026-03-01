// ───────────────────────────────────────────────────────────────
// app_router.dart  –  GoRouter navigation configuration
// ───────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_ludo/core/services/storage_service.dart';
import 'package:dream_ludo/features/splash/presentation/pages/splash_page.dart';
import 'package:dream_ludo/features/auth/presentation/pages/login_page.dart';
import 'package:dream_ludo/features/auth/presentation/pages/register_page.dart';
import 'package:dream_ludo/features/auth/presentation/pages/otp_page.dart';
import 'package:dream_ludo/features/auth/presentation/pages/forgot_page.dart';
import 'package:dream_ludo/features/home/presentation/pages/home_page.dart';
import 'package:dream_ludo/features/match/presentation/pages/match_detail_page.dart';
import 'package:dream_ludo/features/profile/presentation/pages/profile_page.dart';
import 'package:dream_ludo/features/wallet/presentation/pages/deposit_page.dart';
import 'package:dream_ludo/features/wallet/presentation/pages/withdraw_page.dart';
import 'package:dream_ludo/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:dream_ludo/features/history/presentation/pages/history_page.dart';
import 'package:dream_ludo/features/notification/presentation/pages/notification_page.dart';
import 'package:dream_ludo/features/chat/presentation/pages/chat_page.dart';
import 'package:dream_ludo/features/update/presentation/pages/update_app_page.dart';
import 'package:dream_ludo/features/webview/presentation/pages/webview_page.dart';
import 'package:dream_ludo/features/referral/presentation/pages/referral_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String forgot = '/forgot';
  static const String home = '/home';
  static const String matchDetail = '/match/:matchId';
  static const String profile = '/profile';
  static const String deposit = '/deposit';
  static const String withdraw = '/withdraw';
  static const String leaderboard = '/leaderboard';
  static const String history = '/history';
  static const String notification = '/notification';
  static const String chat = '/chat/:matchId';
  static const String updateApp = '/update';
  static const String webview = '/webview';
  static const String referral = '/referral';
  static const String statistics = '/statistics';
}

class AppRouter {
  AppRouter._();

      static final _rootNavigatorKey = GlobalKey<NavigatorState>();
      
      static GoRouter router(StorageService storage) => GoRouter(
            navigatorKey: _rootNavigatorKey,
            initialLocation: AppRoutes.splash,
            redirect: (context, state) async {
              final isLoggedIn = await storage.isLoggedIn();
              final location = state.matchedLocation;
              
              // ignore: avoid_print
              print('🧭 ROUTER: location=$location, isLoggedIn=$isLoggedIn');
      
              final onAuthPages = location == AppRoutes.login ||
                  location == AppRoutes.register ||
                  location == AppRoutes.forgot ||
                  location == AppRoutes.otp;
      
              if (location == AppRoutes.splash) return null;
              
              if (!isLoggedIn && !onAuthPages) {
                // ignore: avoid_print
                print('🧭 ROUTER: → REDIRECT to LOGIN');
                return AppRoutes.login;
              }
              
              if (isLoggedIn && onAuthPages) {
                // ignore: avoid_print
                print('🧭 ROUTER: → REDIRECT to HOME');
                return AppRoutes.home;
              }
              
              return null;
            },
        routes: [
          GoRoute(
            path: AppRoutes.splash,
            builder: (_, __) => const SplashPage(),
          ),
          GoRoute(
            path: AppRoutes.login,
            builder: (_, __) => const LoginPage(),
          ),
          GoRoute(
            path: AppRoutes.register,
            builder: (_, state) {
              final extra = state.extra as Map<String, String>?;
              return RegisterPage(prefillData: extra);
            },
          ),
          GoRoute(
            path: AppRoutes.otp,
            builder: (_, state) {
              final extra = state.extra as Map<String, String>? ?? {};
              return OtpPage(
                mobile: extra['mobile'] ?? '',
                pageKey: extra['pageKey'] ?? 'Register',
              );
            },
          ),
          GoRoute(
            path: AppRoutes.forgot,
            builder: (_, __) => const ForgotPage(),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.matchDetail,
            builder: (_, state) {
              final matchId = state.pathParameters['matchId']!;
              return MatchDetailPage(matchId: matchId);
            },
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.deposit,
            builder: (_, __) => const DepositPage(),
          ),
          GoRoute(
            path: AppRoutes.withdraw,
            builder: (_, __) => const WithdrawPage(),
          ),
          GoRoute(
            path: AppRoutes.leaderboard,
            builder: (_, __) => const LeaderboardPage(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (_, __) => const HistoryPage(),
          ),
          GoRoute(
            path: AppRoutes.notification,
            builder: (_, __) => const NotificationPage(),
          ),
          GoRoute(
            path: AppRoutes.chat,
            builder: (_, state) {
              final matchId = state.pathParameters['matchId']!;
              return ChatPage(matchId: matchId);
            },
          ),
          GoRoute(
            path: AppRoutes.updateApp,
            builder: (_, state) {
              final extra = state.extra as Map<String, String>?;
              return UpdateAppPage(updateData: extra);
            },
          ),
          GoRoute(
            path: AppRoutes.webview,
            builder: (_, state) {
              final extra = state.extra as Map<String, String>?;
              return WebviewPage(
                url: extra?['url'] ?? '',
                title: extra?['title'] ?? '',
              );
            },
          ),
          GoRoute(
            path: AppRoutes.statistics,
            builder: (_, __) => const LeaderboardPage(), // For now
          ),
          GoRoute(
            path: AppRoutes.referral,
            builder: (_, __) => const ReferralPage(),
          ),
        ],
        errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Text('Route not found: ${state.uri}'),
          ),
        ),
      );
}
