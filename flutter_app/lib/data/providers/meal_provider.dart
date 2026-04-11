import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';

/// Selected date for diet tracking (defaults to today)
final selectedMealDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Provider for meals on the selected date
final mealsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final date = ref.watch(selectedMealDateProvider);
  final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  final service = MealService();
  return await service.getMeals(date: dateStr);
});

/// Food search results provider
final foodSearchProvider = FutureProvider.family<List<FoodItemModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final service = MealService();
  return await service.searchFood(query);
});

/// Diet tips provider
final dietTipsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = MealService();
  return await service.getDietTips();
});

/// State notifier for adding a meal
class MealNotifier extends StateNotifier<AsyncValue<void>> {
  MealNotifier() : super(const AsyncData(null));
  final MealService _service = MealService();

  Future<bool> addMeal(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _service.addMeal(data);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteMeal(String mealId) async {
    try {
      await _service.deleteMeal(mealId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final mealNotifierProvider = StateNotifierProvider<MealNotifier, AsyncValue<void>>((ref) {
  return MealNotifier();
});
