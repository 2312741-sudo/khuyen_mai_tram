import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({AppUser? user, bool? isLoading, String? error, bool? isAuthenticated, bool clearError = false}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        state = AuthState(user: user, isAuthenticated: true);
      } else {
        state = state.copyWith(isLoading: false, error: 'Không tìm thấy tài khoản');
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: AuthService.parseAuthError(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Lỗi đăng nhập: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        state = AuthState(user: user, isAuthenticated: true);
      } else {
        state = state.copyWith(isLoading: false, error: 'Đăng nhập Google không thành công');
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: AuthService.parseAuthError(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Lỗi đăng nhập Google: $e');
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.signInWithApple();
      if (user != null) {
        state = AuthState(user: user, isAuthenticated: true);
      } else {
        state = state.copyWith(isLoading: false, error: 'Đăng nhập Apple không thành công');
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: AuthService.parseAuthError(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Lỗi đăng nhập Apple: $e');
    }
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = AuthState(user: user, isAuthenticated: true);
      } else {
        state = const AuthState();
      }
    } catch (e) {
      state = const AuthState();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

final currentRoleProvider = Provider<KmtRole?>((ref) {
  return ref.watch(authProvider).user?.role;
});
