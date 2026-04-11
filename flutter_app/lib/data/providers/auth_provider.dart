import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// AsyncNotifier for authentication state
/// Manages user session, login, signup, and logout
class AuthNotifier extends AsyncNotifier<UserModel?> {
  late final AuthService _authService;

  @override
  Future<UserModel?> build() async {
    _authService = AuthService();
    // On app start, check if user is already authenticated
    if (await _authService.isAuthenticated()) {
      try {
        return await _authService.getMe();
      } catch (_) {
        // Token invalid/expired - return guest user for development
        return UserModel.guest();
      }
    }
    // Return guest user by default to bypass login
    return UserModel.guest();
  }

  /// Login with email + password
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _authService.login(email: email, password: password);
      return result['user'] as UserModel;
    });
  }

  /// Register new account
  Future<void> signup(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _authService.signup(name: name, email: email, password: password);
      return result['user'] as UserModel;
    });
  }

  /// Google Sign-In
  Future<void> googleSignIn({
    required String googleId,
    required String email,
    required String name,
    String? avatar,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _authService.googleAuth(
        googleId: googleId,
        email: email,
        name: name,
        avatar: avatar,
      );
      return result['user'] as UserModel;
    });
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final currentUser = state.value;
    if (currentUser == null) return;
    state = await AsyncValue.guard(() async {
      return await _authService.updateProfile(updates);
    });
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncData(null);
  }
}

/// Global auth state provider
final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

/// Convenience provider to get current user (non-null when logged in)
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).value;
});
