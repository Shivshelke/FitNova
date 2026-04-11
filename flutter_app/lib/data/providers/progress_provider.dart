import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress_model.dart';
import '../services/api_service.dart';
import '../../core/constants.dart';

/// Progress Service
class ProgressService {
  final ApiService _api = ApiService();

  Future<ProgressLogModel?> getTodayProgress() async {
    try {
      final response = await _api.get('${AppConstants.progressEndpoint}/today');
      if (response.data['log'] == null) return null;
      return ProgressLogModel.fromJson(response.data['log']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<ProgressLogModel>> getProgressRange({String range = 'week'}) async {
    try {
      final response = await _api.get(
        AppConstants.progressEndpoint,
        queryParams: {'range': range},
      );
      final list = response.data['logs'] as List;
      return list.map((l) => ProgressLogModel.fromJson(l)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getWeightHistory({String range = 'month'}) async {
    try {
      final response = await _api.get(
        AppConstants.weightHistoryEndpoint,
        queryParams: {'range': range},
      );
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ProgressLogModel> logProgress(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(AppConstants.progressEndpoint, data: data);
      return ProgressLogModel.fromJson(response.data['log']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final todayProgressProvider = FutureProvider<ProgressLogModel?>((ref) async {
  return ProgressService().getTodayProgress();
});

final progressRangeProvider = FutureProvider.family<List<ProgressLogModel>, String>((ref, range) async {
  return ProgressService().getProgressRange(range: range);
});

final weightHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, range) async {
  return ProgressService().getWeightHistory(range: range);
});

class ProgressLogNotifier extends StateNotifier<AsyncValue<void>> {
  ProgressLogNotifier() : super(const AsyncData(null));
  final ProgressService _service = ProgressService();

  Future<bool> logProgress(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _service.logProgress(data);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

final progressLogNotifierProvider = StateNotifierProvider<ProgressLogNotifier, AsyncValue<void>>((ref) {
  return ProgressLogNotifier();
});
