import 'package:dio/dio.dart';
import '../models/workout_model.dart';
import '../services/api_service.dart';
import '../../core/constants.dart';

/// Workout service - handles fetching and creating workouts + logging
class WorkoutService {
  final ApiService _api = ApiService();

  /// Get all workouts (predefined + user's custom)
  Future<List<WorkoutModel>> getWorkouts({String? type, String? difficulty, String? goal}) async {
    try {
      final response = await _api.get(
        AppConstants.workoutsEndpoint,
        queryParams: {
          if (type != null) 'type': type,
          if (difficulty != null) 'difficulty': difficulty,
          if (goal != null) 'goal': goal,
        },
      );
      final list = response.data['workouts'] as List;
      return list.map((w) => WorkoutModel.fromJson(w)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get a single workout by ID
  Future<WorkoutModel> getWorkout(String id) async {
    try {
      final response = await _api.get('${AppConstants.workoutsEndpoint}/$id');
      return WorkoutModel.fromJson(response.data['workout']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Create a custom workout
  Future<WorkoutModel> createWorkout(Map<String, dynamic> workoutData) async {
    try {
      final response = await _api.post(AppConstants.workoutsEndpoint, data: workoutData);
      return WorkoutModel.fromJson(response.data['workout']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Log a completed workout session
  Future<WorkoutLogModel> logWorkout(Map<String, dynamic> logData) async {
    try {
      final response = await _api.post(AppConstants.workoutLogsEndpoint, data: logData);
      return WorkoutLogModel.fromJson(response.data['log']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get workout history
  Future<List<WorkoutLogModel>> getWorkoutHistory({String? startDate, String? endDate}) async {
    try {
      final response = await _api.get(
        AppConstants.workoutLogsEndpoint,
        queryParams: {
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        },
      );
      final list = response.data['logs'] as List;
      return list.map((l) => WorkoutLogModel.fromJson(l)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get AI workout suggestions
  Future<Map<String, dynamic>> getWorkoutSuggestions() async {
    try {
      final response = await _api.get(AppConstants.workoutSuggestionsEndpoint);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
