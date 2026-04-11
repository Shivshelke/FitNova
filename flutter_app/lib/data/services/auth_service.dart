import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../../core/constants.dart';

/// Authentication service - handles signup, login, Google auth, profile
class AuthService {
  final ApiService _api = ApiService();

  /// Register new user
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        AppConstants.signupEndpoint,
        data: {'name': name, 'email': email, 'password': password},
      );
      final data = response.data;
      // Save token locally
      await _api.saveToken(data['token']);
      return {'token': data['token'], 'user': UserModel.fromJson(data['user'])};
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Login with email + password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        AppConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      await _api.saveToken(data['token']);
      return {'token': data['token'], 'user': UserModel.fromJson(data['user'])};
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Google Sign-In (pass googleId and email from Google Sign-In SDK)
  Future<Map<String, dynamic>> googleAuth({
    required String googleId,
    required String email,
    required String name,
    String? avatar,
  }) async {
    try {
      final response = await _api.post(
        AppConstants.googleAuthEndpoint,
        data: {'googleId': googleId, 'email': email, 'name': name, 'avatar': avatar},
      );
      final data = response.data;
      await _api.saveToken(data['token']);
      return {'token': data['token'], 'user': UserModel.fromJson(data['user'])};
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Fetch current user profile
  Future<UserModel> getMe() async {
    try {
      final response = await _api.get(AppConstants.meEndpoint);
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Update user profile (age, weight, height, goal, etc.)
  Future<UserModel> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _api.put(AppConstants.profileEndpoint, data: updates);
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Logout - clear stored token
  Future<void> logout() async {
    await _api.clearAuth();
  }

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    return await _api.isAuthenticated();
  }
}
