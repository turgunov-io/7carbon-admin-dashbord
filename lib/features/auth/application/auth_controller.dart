import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_error.dart';
import '../data/auth_repository.dart';
import '../data/auth_token_storage.dart';

class AuthState {
  const AuthState({
    required this.token,
    required this.submitting,
    this.errorMessage,
  });

  final String? token;
  final bool submitting;
  final String? errorMessage;

  bool get isAuthenticated {
    final value = token?.trim() ?? '';
    return value.isNotEmpty;
  }

  AuthState copyWith({
    String? token,
    bool? submitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      token: token ?? this.token,
      submitting: submitting ?? this.submitting,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  factory AuthState.initial() {
    final initialToken = AppConfig.adminToken.trim();
    return AuthState(
      token: initialToken.isEmpty ? null : initialToken,
      submitting: false,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = AuthRepository.create();
  ref.onDispose(repository.dispose);
  return repository;
});

final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  return const AuthTokenStorage();
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      ref.watch(authRepositoryProvider),
      ref.watch(authTokenStorageProvider),
    );
  },
);

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).token;
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository, this._tokenStorage)
    : super(AuthState.initial()) {
    unawaited(_restoreSession());
  }

  final AuthRepository _repository;
  final AuthTokenStorage _tokenStorage;

  Future<void> _restoreSession() async {
    if (state.isAuthenticated) {
      return;
    }

    try {
      final savedToken = await _tokenStorage.readToken();
      if (!mounted || savedToken == null || savedToken.isEmpty) {
        return;
      }

      state = state.copyWith(
        token: savedToken,
        submitting: false,
        clearErrorMessage: true,
      );
    } catch (_) {
      // Ignore restore failures and let user log in again.
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    final hasPassword = password.trim().isNotEmpty;

    if (normalizedUsername.isEmpty || !hasPassword) {
      state = state.copyWith(
        submitting: false,
        errorMessage: 'Введите логин и пароль.',
      );
      return false;
    }

    state = state.copyWith(submitting: true, clearErrorMessage: true);

    try {
      final token = await _repository.login(
        username: normalizedUsername,
        password: password,
      );

      try {
        await _tokenStorage.saveToken(token);
      } catch (_) {
        // Storage failure should not block successful login in this session.
      }

      if (!mounted) {
        return false;
      }

      state = AuthState(token: token, submitting: false);
      return true;
    } on ApiError catch (error) {
      state = state.copyWith(
        submitting: false,
        errorMessage: _humanizeAuthError(error),
      );
      return false;
    } catch (error) {
      state = state.copyWith(
        submitting: false,
        errorMessage: 'Ошибка входа: $error',
      );
      return false;
    }
  }

  void logout() {
    state = const AuthState(token: null, submitting: false);
    unawaited(_tokenStorage.clearToken());
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    state = state.copyWith(clearErrorMessage: true);
  }

  String _humanizeAuthError(ApiError error) {
    final message = error.message.trim();
    final normalized = message.toLowerCase();

    if (normalized.contains('invalid credentials') ||
        normalized.contains('invalid credential')) {
      return 'Ввели неправильные данные';
    }

    return message;
  }
}
