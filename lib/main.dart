// ───────────────────────────────────────────────────────────────
// main.dart  –  DreamLudo Flutter App Entry Point
// Architecture: Clean Architecture + BLoC + GoRouter + GetIt
// ───────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_ludo/core/di/service_locator.dart';
import 'package:dream_ludo/core/router/app_router.dart';
import 'package:dream_ludo/core/services/storage_service.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_ludo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dream_ludo/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:dream_ludo/features/match/presentation/bloc/match_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase (Removed)

  // Setup dependency injection
  await setupServiceLocator();

  runApp(const DreamLudoApp());
}

class DreamLudoApp extends StatefulWidget {
  const DreamLudoApp({super.key});

  @override
  State<DreamLudoApp> createState() => _DreamLudoAppState();
}

class _DreamLudoAppState extends State<DreamLudoApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.router(sl<StorageService>());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<SplashBloc>()),
        BlocProvider(create: (_) => sl<MatchBloc>()),
      ],
      child: MaterialApp.router(
        title: 'DreamLudo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: _router,
      ),
    );
  }
}
