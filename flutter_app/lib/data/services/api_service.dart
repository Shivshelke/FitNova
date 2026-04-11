import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants.dart';

/// Base API Service
/// Configures Dio HTTP client with JWT auth interceptor
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // ── Auth Interceptor ──────────────────────────────────────────────────────
    // Automatically adds JWT Bearer token to every request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 globally (token expired)
          if (error.response?.statusCode == 401) {
            // Token expired - caller should handle redirect to login
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// Save auth token to secure storage
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  /// Clear all auth data (logout)
  Future<void> clearAuth() async {
    await _storage.deleteAll();
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    return token != null;
  }

  // ── Generic HTTP helpers ──────────────────────────────────────────────────────

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    return await _dio.get(endpoint, queryParameters: queryParams);
  }

  Future<Response> post(String endpoint, {dynamic data}) async {
    return await _dio.post(endpoint, data: data);
  }

  Future<Response> put(String endpoint, {dynamic data}) async {
    return await _dio.put(endpoint, data: data);
  }

  Future<Response> delete(String endpoint) async {
    return await _dio.delete(endpoint);
  }
}

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  /// Extracts error message from DioException
  static ApiException fromDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      final message = data is Map ? (data['message'] ?? 'Request failed') : 'Request failed';
      return ApiException(message, statusCode: e.response!.statusCode);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException('Connection timeout. Please check your internet.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return ApiException('Cannot connect to server. Make sure the backend is running.');
    }
    return ApiException('An unexpected error occurred.');
  }
}
