// ───────────────────────────────────────────────────────────────
// service_locator.dart  –  Dependency injection with GetIt
// Register all singletons & factories here
// ───────────────────────────────────────────────────────────────

import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dream_ludo/core/network/dio_client.dart';
import 'package:dream_ludo/core/services/storage_service.dart';
import 'package:dream_ludo/core/services/websocket_service.dart';
import 'package:dream_ludo/core/services/socket_service.dart';
import 'package:dream_ludo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dream_ludo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dream_ludo/features/auth/domain/repositories/auth_repository.dart';
import 'package:dream_ludo/features/auth/domain/usecases/login_usecase.dart';
import 'package:dream_ludo/features/auth/domain/usecases/register_usecase.dart';
import 'package:dream_ludo/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:dream_ludo/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:dream_ludo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dream_ludo/features/match/data/datasources/match_remote_datasource.dart';
import 'package:dream_ludo/features/match/data/repositories/match_repository_impl.dart';
import 'package:dream_ludo/features/match/domain/repositories/match_repository.dart';
import 'package:dream_ludo/features/match/domain/usecases/get_matches_usecase.dart';
import 'package:dream_ludo/features/match/presentation/bloc/match_bloc.dart';
import 'package:dream_ludo/features/splash/data/datasources/app_remote_datasource.dart';
import 'package:dream_ludo/features/splash/data/repositories/app_repository_impl.dart';
import 'package:dream_ludo/features/splash/domain/repositories/app_repository.dart';
import 'package:dream_ludo/features/splash/domain/usecases/get_app_details_usecase.dart';
import 'package:dream_ludo/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:dream_ludo/features/rewards/presentation/bloc/rewards_bloc.dart';
import 'package:dream_ludo/features/online_game/presentation/bloc/online_ludo_bloc.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ── External ──────────────────────────────────────────────────

  final pref = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(pref);
  sl.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );

  // ── Core Services ─────────────────────────────────────────────

  sl.registerSingleton<StorageService>(
    StorageService(sl<FlutterSecureStorage>(), sl<SharedPreferences>()),
  );

  sl.registerSingleton<DioClient>(DioClient(sl<StorageService>()));

  sl.registerSingleton<WebSocketService>(WebSocketService(sl<StorageService>()));

  // ── Auth Feature ──────────────────────────────────────────────

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<StorageService>()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<AuthRepository>()));
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      getProfileUseCase: sl<GetProfileUseCase>(),
      updateProfileUseCase: sl<UpdateProfileUseCase>(),
      storage: sl<StorageService>(),
    ),
  );

  // ── Splash / App Details Feature ──────────────────────────────

  sl.registerLazySingleton<AppRemoteDataSource>(
    () => AppRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AppRepository>(
    () => AppRepositoryImpl(sl<AppRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetAppDetailsUseCase(sl<AppRepository>()));
  sl.registerFactory(
    () => SplashBloc(
      getAppDetailsUseCase: sl<GetAppDetailsUseCase>(),
      storage: sl<StorageService>(),
    ),
  );

  // ── Match Feature ─────────────────────────────────────────────

  sl.registerLazySingleton<MatchRemoteDataSource>(
    () => MatchRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<MatchRepository>(
    () => MatchRepositoryImpl(sl<MatchRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetMatchesUseCase(sl<MatchRepository>()));
  sl.registerFactory(
    () => MatchBloc(
      getMatchesUseCase: sl<GetMatchesUseCase>(),
      storage: sl<StorageService>(),
      socketService: sl<SocketService>(),
    ),
  );

  // ── Rewards Feature ───────────────────────────────────────────
  sl.registerFactory(() => RewardsBloc());

  // ── Game / Sockets ─────────────────────────────────────────────
  sl.registerSingleton<SocketService>(SocketService(sl<StorageService>()));
  sl.registerFactory(() => OnlineLudoBloc(sl<SocketService>()));
}
