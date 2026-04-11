/// Workout data model
class WorkoutModel {
  final String id;
  final String name;
  final String description;
  final String type; // gym, home, outdoor
  final String difficulty;
  final String targetGoal;
  final int estimatedDuration; // minutes
  final int estimatedCalories;
  final List<ExerciseModel> exercises;
  final bool isPredefined;
  final String? createdBy;
  final String category;

  WorkoutModel({
    required this.id,
    required this.name,
    this.description = '',
    this.type = 'gym',
    this.difficulty = 'beginner',
    this.targetGoal = 'all',
    this.estimatedDuration = 45,
    this.estimatedCalories = 300,
    this.exercises = const [],
    this.isPredefined = false,
    this.createdBy,
    this.category = 'General',
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'gym',
      difficulty: json['difficulty'] ?? 'beginner',
      targetGoal: json['targetGoal'] ?? 'all',
      estimatedDuration: json['estimatedDuration'] ?? 45,
      estimatedCalories: json['estimatedCalories'] ?? 300,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseModel.fromJson(e))
              .toList() ??
          [],
      isPredefined: json['isPredefined'] ?? false,
      createdBy: json['createdBy'],
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'type': type,
        'difficulty': difficulty,
        'targetGoal': targetGoal,
        'estimatedDuration': estimatedDuration,
        'estimatedCalories': estimatedCalories,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'category': category,
      };
}

/// Exercise within a workout
class ExerciseModel {
  final String name;
  final String muscleGroup;
  final int defaultSets;
  final int defaultReps;
  final double defaultWeight;
  final int? duration; // seconds

  ExerciseModel({
    required this.name,
    this.muscleGroup = 'full_body',
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.defaultWeight = 0,
    this.duration,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      name: json['name'] ?? '',
      muscleGroup: json['muscleGroup'] ?? 'full_body',
      defaultSets: json['defaultSets'] ?? 3,
      defaultReps: json['defaultReps'] ?? 10,
      defaultWeight: (json['defaultWeight'] as num?)?.toDouble() ?? 0,
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'muscleGroup': muscleGroup,
        'defaultSets': defaultSets,
        'defaultReps': defaultReps,
        'defaultWeight': defaultWeight,
        'duration': duration,
      };
}

/// Workout log entry (completed session)
class WorkoutLogModel {
  final String id;
  final String workoutName;
  final int totalDuration;
  final int caloriesBurned;
  final DateTime date;
  final List<Map<String, dynamic>> exercises;

  WorkoutLogModel({
    required this.id,
    required this.workoutName,
    this.totalDuration = 0,
    this.caloriesBurned = 0,
    required this.date,
    this.exercises = const [],
  });

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogModel(
      id: json['_id'] ?? '',
      workoutName: json['workoutName'] ?? '',
      totalDuration: json['totalDuration'] ?? 0,
      caloriesBurned: json['caloriesBurned'] ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      exercises: List<Map<String, dynamic>>.from(json['exercises'] ?? []),
    );
  }
}
