import 'dart:convert';

/// User data model matching the backend User schema
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? googleId;
  final String? avatar;
  final int? age;
  final double? weight;
  final double? height;
  final String? gender;
  final String goal;
  final int dailyCalorieTarget;
  final int dailyStepsTarget;
  final int dailyWaterTarget;
  final bool darkMode;
  final bool notificationsEnabled;
  final bool profileComplete;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.googleId,
    this.avatar,
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.goal = 'maintenance',
    this.dailyCalorieTarget = 2000,
    this.dailyStepsTarget = 10000,
    this.dailyWaterTarget = 2500,
    this.darkMode = true,
    this.notificationsEnabled = true,
    this.profileComplete = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      googleId: json['googleId'],
      avatar: json['avatar'],
      age: json['age'],
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      gender: json['gender'],
      goal: json['goal'] ?? 'maintenance',
      dailyCalorieTarget: json['dailyCalorieTarget'] ?? 2000,
      dailyStepsTarget: json['dailyStepsTarget'] ?? 10000,
      dailyWaterTarget: json['dailyWaterTarget'] ?? 2500,
      darkMode: json['darkMode'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      profileComplete: json['profileComplete'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'googleId': googleId,
        'avatar': avatar,
        'age': age,
        'weight': weight,
        'height': height,
        'gender': gender,
        'goal': goal,
        'dailyCalorieTarget': dailyCalorieTarget,
        'dailyStepsTarget': dailyStepsTarget,
        'dailyWaterTarget': dailyWaterTarget,
        'darkMode': darkMode,
        'notificationsEnabled': notificationsEnabled,
        'profileComplete': profileComplete,
      };

  /// BMI calculation helper
  double? get bmi {
    if (weight == null || height == null || height == 0) return null;
    final heightInM = height! / 100;
    return weight! / (heightInM * heightInM);
  }

  String get goalLabel {
    const labels = {
      'weight_loss': 'Weight Loss',
      'weight_gain': 'Weight Gain',
      'maintenance': 'Maintenance',
      'muscle_building': 'Muscle Building',
    };
    return labels[goal] ?? goal;
  }

  UserModel copyWith({
    String? name,
    String? avatar,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? goal,
    int? dailyCalorieTarget,
    int? dailyStepsTarget,
    int? dailyWaterTarget,
    bool? profileComplete,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      googleId: googleId,
      avatar: avatar ?? this.avatar,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      dailyStepsTarget: dailyStepsTarget ?? this.dailyStepsTarget,
      dailyWaterTarget: dailyWaterTarget ?? this.dailyWaterTarget,
      darkMode: darkMode,
      notificationsEnabled: notificationsEnabled,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }

  /// Default mock user for development
  factory UserModel.guest() {
    return UserModel(
      id: 'guest_user_123',
      name: 'Guest User',
      email: 'guest@fitnova.app',
      age: 25,
      weight: 70,
      height: 175,
      gender: 'male',
      goal: 'maintenance',
      profileComplete: true,
    );
  }
}
