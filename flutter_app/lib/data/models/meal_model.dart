/// Meal data model for diet tracking
class MealModel {
  final String id;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime date;
  final List<MealItemModel> items;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final String notes;

  MealModel({
    required this.id,
    required this.mealType,
    required this.date,
    this.items = const [],
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.notes = '',
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['_id'] ?? '',
      mealType: json['mealType'] ?? 'snack',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MealItemModel.fromJson(e))
              .toList() ??
          [],
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'mealType': mealType,
        'date': date.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'notes': notes,
      };

  String get mealTypeLabel {
    const labels = {
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'dinner': 'Dinner',
      'snack': 'Snack',
    };
    return labels[mealType] ?? mealType;
  }
}

/// Individual food item within a meal
class MealItemModel {
  final String foodName;
  final double quantity;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  MealItemModel({
    required this.foodName,
    this.quantity = 1,
    this.unit = 'serving',
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
      foodName: json['foodName'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      unit: json['unit'] ?? 'serving',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'foodName': foodName,
        'quantity': quantity,
        'unit': unit,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
}

/// Food item from the food database
class FoodItemModel {
  final String id;
  final String name;
  final String brand;
  final String category;
  final double servingSize;
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  FoodItemModel({
    required this.id,
    required this.name,
    this.brand = 'Generic',
    this.category = 'other',
    this.servingSize = 100,
    this.servingUnit = 'g',
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? 'Generic',
      category: json['category'] ?? 'other',
      servingSize: (json['servingSize'] as num?)?.toDouble() ?? 100,
      servingUnit: json['servingUnit'] ?? 'g',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
    );
  }
}
