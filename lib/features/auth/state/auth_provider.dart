import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/bank_error.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

/// The current authenticated session.
/// null = not logged in, UserSession = logged in.
final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserSession?>(
  AuthNotifier.new,
);

/// Manages authentication state.
/// On app start, attempts to restore a session from secure storage.
class AuthNotifier extends AsyncNotifier<UserSession?> {
  @override
  Future<UserSession?> build() async {
    // Attempt session restoration on app startup.
    final repo = ref.watch(authRepositoryProvider);
    return repo.restoreSession();
  }

  /// Login with customer ID and PIN.
  Future<void> login(LoginRequest request) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final session = await repo.login(request);
      state = AsyncData(session);
    } on BankError catch (e) {
      state = AsyncError(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Logout and clear session.
  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(null);
  }
}

/// Convenience provider: whether a session is active.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull != null;
});
