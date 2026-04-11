import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_model.dart';
import '../services/workout_service.dart';

/// Provider for the list of workouts (predefined + custom)
final workoutsProvider = FutureProvider.family<List<WorkoutModel>, Map<String, String?>>((ref, filters) async {
  final service = WorkoutService();
  return await service.getWorkouts(
    type: filters['type'],
    difficulty: filters['difficulty'],
    goal: filters['goal'],
  );
});

/// Simple workouts provider (no filter)
final allWorkoutsProvider = FutureProvider<List<WorkoutModel>>((ref) async {
  final service = WorkoutService();
  return await service.getWorkouts();
});

/// Workout history provider
final workoutHistoryProvider = FutureProvider<List<WorkoutLogModel>>((ref) async {
  final service = WorkoutService();
  return await service.getWorkoutHistory();
});

/// AI workout suggestions provider
final workoutSuggestionsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = WorkoutService();
  return await service.getWorkoutSuggestions();
});

/// State notifier for logging a workout session
class WorkoutLogNotifier extends StateNotifier<AsyncValue<WorkoutLogModel?>> {
  WorkoutLogNotifier() : super(const AsyncData(null));
  final WorkoutService _service = WorkoutService();

  Future<void> logWorkout(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.logWorkout(data));
  }
}

final workoutLogNotifierProvider =
    StateNotifierProvider<WorkoutLogNotifier, AsyncValue<WorkoutLogModel?>>((ref) {
  return WorkoutLogNotifier();
});
