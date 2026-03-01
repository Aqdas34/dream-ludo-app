// ── splash_bloc.dart  –  Splash screen logic ─────────────────────
// Mirrors: Java → SplashActivity.java logic

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dream_ludo/core/constants/app_constants.dart';
import 'package:dream_ludo/core/services/storage_service.dart';
import 'package:dream_ludo/features/splash/data/models/app_model.dart';
import 'package:dream_ludo/features/splash/domain/usecases/get_app_details_usecase.dart';

// ── Events ────────────────────────────────────────────────────

abstract class SplashEvent extends Equatable {
  const SplashEvent();
  @override
  List<Object?> get props => [];
}

class SplashInitialized extends SplashEvent {}

// ── States ────────────────────────────────────────────────────

abstract class SplashState extends Equatable {
  const SplashState();
  @override
  List<Object?> get props => [];
}

class SplashLoading extends SplashState {}

class SplashNavigateToHome extends SplashState {}

class SplashNavigateToLogin extends SplashState {}

class SplashNavigateToUpdate extends SplashState {
  final Map<String, String> updateData;
  const SplashNavigateToUpdate(this.updateData);
  @override
  List<Object> get props => [updateData];
}

class SplashMaintenance extends SplashState {}

class SplashNoInternet extends SplashState {}

// ── BLoC ──────────────────────────────────────────────────────

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetAppDetailsUseCase _getAppDetailsUseCase;
  final StorageService _storage;

  SplashBloc({
    required GetAppDetailsUseCase getAppDetailsUseCase,
    required StorageService storage,
  })  : _getAppDetailsUseCase = getAppDetailsUseCase,
        _storage = storage,
        super(SplashLoading()) {
    on<SplashInitialized>(_onSplashInitialized);
  }

  Future<void> _onSplashInitialized(
    SplashInitialized event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());

    await Future.delayed(const Duration(milliseconds: 500));

    final result = await _getAppDetailsUseCase();

    await result.fold(
      (failure) async {
        // API failed – check if user is already logged in
        final isLoggedIn = await _storage.isLoggedIn();
        if (isLoggedIn) {
          emit(SplashNavigateToHome());
        } else {
          emit(SplashNavigateToLogin());
        }
      },
      (appModel) async {
        if (appModel.success != 1) {
          final isLoggedIn = await _storage.isLoggedIn();
          emit(isLoggedIn ? SplashNavigateToHome() : SplashNavigateToLogin());
          return;
        }

        // Apply server-side config to AppConstants (mirrors Java SplashActivity)
        _applyConfig(appModel);

        // Version check
        final packageInfo = await PackageInfo.fromPlatform();
        final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
        final latestBuild =
            int.tryParse(appModel.latestVersionCode ?? '0') ?? 0;

        if (currentBuild < latestBuild) {
          emit(SplashNavigateToUpdate({
            'forceUpdate': appModel.forceUpdate ?? '0',
            'whatsNew': appModel.whatsNew ?? '',
            'updateDate': appModel.updateDate ?? '',
            'latestVersionName': appModel.latestVersionName ?? '',
            'updateUrl': appModel.updateUrl ?? '',
          }));
          return;
        }

        if ((appModel.maintenanceMode ?? 0) == 1) {
          emit(SplashMaintenance());
          return;
        }

        await Future.delayed(const Duration(milliseconds: 500));
        final isLoggedIn = await _storage.isLoggedIn();
        emit(isLoggedIn ? SplashNavigateToHome() : SplashNavigateToLogin());
      },
    );
  }

  void _applyConfig(AppModel model) {
    if (model.countryCode != null) {
      AppConstants.countryCode = model.countryCode!;
    }
    if (model.currencyCode != null) {
      AppConstants.currencyCode = model.currencyCode!;
    }
    if (model.currencySign != null) {
      AppConstants.currencySign = model.currencySign!;
    }
    if (model.paytmMerId != null) AppConstants.paytmMId = model.paytmMerId!;
    if (model.payuId != null) AppConstants.payuMId = model.payuId!;
    if (model.payuKey != null) AppConstants.payuMKey = model.payuKey!;
    if (model.minEntryFee != null) {
      AppConstants.minJoinLimit = model.minEntryFee!;
    }
    if (model.referPercentage != null) {
      AppConstants.referralPercentage = model.referPercentage!;
    }
    if (model.maintenanceMode != null) {
      AppConstants.maintenanceMode = model.maintenanceMode!;
    }
    if (model.mop != null) AppConstants.modeOfPayment = model.mop!;
    if (model.walletMode != null) AppConstants.walletMode = model.walletMode!;
    if (model.minWithdraw != null) {
      AppConstants.minWithdrawLimit = model.minWithdraw!;
    }
    if (model.maxWithdraw != null) {
      AppConstants.maxWithdrawLimit = model.maxWithdraw!;
    }
    if (model.minDeposit != null) {
      AppConstants.minDepositLimit = model.minDeposit!;
    }
    if (model.maxDeposit != null) {
      AppConstants.maxDepositLimit = model.maxDeposit!;
    }
    if (model.gameName != null) AppConstants.gameName = model.gameName!;
    if (model.packageName != null) {
      AppConstants.packageName = model.packageName!;
    }
    if (model.howToPlay != null) AppConstants.howToPlay = model.howToPlay!;
    if (model.cusSupportEmail != null) {
      AppConstants.supportEmail = model.cusSupportEmail!;
    }
    if (model.cusSupportMobile != null) {
      AppConstants.supportMobile = model.cusSupportMobile!;
    }
    if (model.updateUrl != null) AppConstants.updateUrl = model.updateUrl!;
  }
}
