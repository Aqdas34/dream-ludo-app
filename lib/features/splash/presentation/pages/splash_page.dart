// ───────────────────────────────────────────────────────────────
// splash_page.dart  –  Matches Kotlin activity_splash.xml exactly
// Background: colorAccent (#FE4D6B→#FE2147), centered app_icon,
// "Please wait..." text at bottom
// ───────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_ludo/core/di/service_locator.dart';
import 'package:dream_ludo/core/router/app_router.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/splash/presentation/bloc/splash_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashBloc>()..add(SplashInitialized()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToLogin) {
            context.go(AppRoutes.login);
          } else if (state is SplashNavigateToHome) {
            context.go(AppRoutes.home);
          } else if (state is SplashNavigateToUpdate) {
            context.go(AppRoutes.updateApp);
          }
        },
        child: const _SplashView(),
      ),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();
  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplashBloc, SplashState>(
      builder: (context, state) {
        final isMaint = state is SplashMaintenance;

        return Scaffold(
          // Solid colorAccent background — exactly like Kotlin
          backgroundColor: AppColors.primary,
          body: Stack(
            children: [
              // CENTER: App icon (scaled animation)
              Center(
                child: ScaleTransition(
                  scale: _scale,
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 160,
                    height: 160,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.casino_rounded,
                      size: 100,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),

              // BOTTOM: Status text — exactly like Kotlin statusTv
              Positioned(
                left: 0,
                right: 0,
                bottom: 75,
                child: Text(
                  isMaint
                      ? 'Under Maintenance\nPlease try again later'
                      : 'Please wait...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.8,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
