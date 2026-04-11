/// Goal data model for user fitness goals
class GoalModel {
  final String id;
  final String goalType;
  final double? targetWeight;
  final double? currentWeight;
  final int? targetCalories;
  final int targetSteps;
  final int targetWater;
  final int targetWorkoutsPerWeek;
  final DateTime startDate;
  final DateTime? deadline;
  final bool isActive;
  final bool isCompleted;
  final double completionPercentage;
  final String notes;

  GoalModel({
    required this.id,
    required this.goalType,
    this.targetWeight,
    this.currentWeight,
    this.targetCalories,
    this.targetSteps = 10000,
    this.targetWater = 2500,
    this.targetWorkoutsPerWeek = 3,
    required this.startDate,
    this.deadline,
    this.isActive = true,
    this.isCompleted = false,
    this.completionPercentage = 0,
    this.notes = '',
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['_id'] ?? '',
      goalType: json['goalType'] ?? 'maintenance',
      targetWeight: (json['targetWeight'] as num?)?.toDouble(),
      currentWeight: (json['currentWeight'] as num?)?.toDouble(),
      targetCalories: json['targetCalories'],
      targetSteps: json['targetSteps'] ?? 10000,
      targetWater: json['targetWater'] ?? 2500,
      targetWorkoutsPerWeek: json['targetWorkoutsPerWeek'] ?? 3,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      isActive: json['isActive'] ?? true,
      isCompleted: json['isCompleted'] ?? false,
      completionPercentage: (json['completionPercentage'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'goalType': goalType,
        'targetWeight': targetWeight,
        'currentWeight': currentWeight,
        'targetCalories': targetCalories,
        'targetSteps': targetSteps,
        'targetWater': targetWater,
        'targetWorkoutsPerWeek': targetWorkoutsPerWeek,
        'deadline': deadline?.toIso8601String(),
        'notes': notes,
      };

  String get goalTypeLabel {
    const labels = {
      'weight_loss': 'Weight Loss',
      'weight_gain': 'Weight Gain',
      'maintenance': 'Maintenance',
      'muscle_building': 'Muscle Building',
    };
    return labels[goalType] ?? goalType;
  }

  /// Days remaining until deadline
  int? get daysRemaining {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }
}
