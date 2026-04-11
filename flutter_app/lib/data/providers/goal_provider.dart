import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal_model.dart';
import '../services/api_service.dart';
import '../../core/constants.dart';

/// Goal Service
class GoalService {
  final ApiService _api = ApiService();

  Future<List<GoalModel>> getGoals() async {
    try {
      final response = await _api.get(AppConstants.goalsEndpoint);
      final list = response.data['goals'] as List;
      return list.map((g) => GoalModel.fromJson(g)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<GoalModel> createGoal(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(AppConstants.goalsEndpoint, data: data);
      return GoalModel.fromJson(response.data['goal']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<GoalModel> updateGoal(String id, Map<String, dynamic> data) async {
    try {
      final response = await _api.put('${AppConstants.goalsEndpoint}/$id', data: data);
      return GoalModel.fromJson(response.data['goal']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _api.delete('${AppConstants.goalsEndpoint}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getGoalCompletion() async {
    try {
      final response = await _api.get(AppConstants.goalCompletionEndpoint);
      return List<Map<String, dynamic>>.from(response.data['completionData']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _api.get(AppConstants.dashboardEndpoint);
      return response.data['summary'];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final goalsProvider = FutureProvider<List<GoalModel>>((ref) async {
  return GoalService().getGoals();
});

final goalCompletionProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return GoalService().getGoalCompletion();
});

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return GoalService().getDashboard();
});

class GoalNotifier extends StateNotifier<AsyncValue<List<GoalModel>>> {
  GoalNotifier() : super(const AsyncLoading());
  final GoalService _service = GoalService();

  Future<void> loadGoals() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.getGoals());
  }

  Future<bool> createGoal(Map<String, dynamic> data) async {
    try {
      await _service.createGoal(data);
      await loadGoals();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteGoal(String id) async {
    try {
      await _service.deleteGoal(id);
      await loadGoals();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final goalNotifierProvider = StateNotifierProvider<GoalNotifier, AsyncValue<List<GoalModel>>>((ref) {
  return GoalNotifier()..loadGoals();
});
