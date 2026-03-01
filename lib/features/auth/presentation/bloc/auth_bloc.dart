// ───────────────────────────────────────────────────────────────
// auth_bloc.dart  –  Auth state management (BLoC)
// Handles: Login, Register, Social-Auth, Logout
// Replaces: Java → LoginActivity setState logic
// ───────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dream_ludo/core/services/storage_service.dart';
import 'package:dream_ludo/features/auth/data/models/user_model.dart';
import 'package:dream_ludo/features/auth/domain/usecases/login_usecase.dart';
import 'package:dream_ludo/features/auth/domain/usecases/register_usecase.dart';

// ── Events ────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String type;

  const LoginRequested({
    required this.email,
    required this.password,
    this.type = 'regular',
  });

  @override
  List<Object> get props => [email, password, type];
}

class RegisterRequested extends AuthEvent {
  final RegisterParams params;
  const RegisterRequested(this.params);

  @override
  List<Object> get props => [params];
}

class SocialLoginRequested extends AuthEvent {
  final String name;
  final String email;
  final String socialId;
  final String type; // 'google' | 'facebook'

  const SocialLoginRequested({
    required this.name,
    required this.email,
    required this.socialId,
    required this.type,
  });

  @override
  List<Object> get props => [email, socialId, type];
}

class LogoutRequested extends AuthEvent {}

// ── States ────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  const AuthSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState(this.message);

  @override
  List<Object> get props => [message];
}

class AuthSocialLoginNeedsRegistration extends AuthState {
  final String name;
  final String email;
  final String username;
  final String socialId;

  const AuthSocialLoginNeedsRegistration({
    required this.name,
    required this.email,
    required this.username,
    required this.socialId,
  });
}

class LogoutSuccess extends AuthState {}

// ── BLoC ──────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final StorageService _storage;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required StorageService storage,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _storage = storage,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
        type: event.type,
      ),
    );

    result.fold(
      (failure) {
        // ignore: avoid_print
        print('LOGIN FAILED: ${failure.message}');
        emit(AuthFailureState(failure.message));
      },
      (user) {
        // ignore: avoid_print
        print('LOGIN SUCCESS: ${user.username}');
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _registerUseCase(event.params);

    result.fold(
      (failure) {
        // ignore: avoid_print
        print('REGISTER FAILED: ${failure.message}');
        emit(AuthFailureState(failure.message));
      },
      (user) {
        // ignore: avoid_print
        print('REGISTER SUCCESS: ${user.username}');
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onSocialLoginRequested(
    SocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _loginUseCase(
      LoginParams(
        email: event.email,
        password: event.socialId,
        type: 'social',
      ),
    );

    result.fold(
      (failure) {
        final username =
            event.email.contains('@') ? event.email.split('@')[0] : event.email;
        emit(AuthSocialLoginNeedsRegistration(
          name: event.name,
          email: event.email,
          username: username,
          socialId: event.socialId,
        ));
      },
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _storage.clearAll();
    emit(LogoutSuccess());
  }
}
