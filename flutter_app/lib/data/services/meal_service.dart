import 'package:dio/dio.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';
import '../../core/constants.dart';

/// Meal service - handles meal logging and food search
class MealService {
  final ApiService _api = ApiService();

  /// Get meals for a date
  Future<Map<String, dynamic>> getMeals({String? date}) async {
    try {
      final response = await _api.get(
        AppConstants.mealsEndpoint,
        queryParams: {if (date != null) 'date': date},
      );
      final meals = (response.data['meals'] as List)
          .map((m) => MealModel.fromJson(m))
          .toList();
      return {
        'meals': meals,
        'dailyTotals': response.data['dailyTotals'],
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Log a new meal
  Future<MealModel> addMeal(Map<String, dynamic> mealData) async {
    try {
      final response = await _api.post(AppConstants.mealsEndpoint, data: mealData);
      return MealModel.fromJson(response.data['meal']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Delete a meal
  Future<void> deleteMeal(String mealId) async {
    try {
      await _api.delete('${AppConstants.mealsEndpoint}/$mealId');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Search food items
  Future<List<FoodItemModel>> searchFood(String query) async {
    try {
      final response = await _api.get(
        AppConstants.foodSearchEndpoint,
        queryParams: {'q': query},
      );
      final list = response.data['foods'] as List;
      return list.map((f) => FoodItemModel.fromJson(f)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get AI diet tips
  Future<Map<String, dynamic>> getDietTips() async {
    try {
      final response = await _api.get(AppConstants.dietTipsEndpoint);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
