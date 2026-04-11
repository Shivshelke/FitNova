/// Progress log data model for daily health tracking
class ProgressLogModel {
  final String id;
  final DateTime date;
  final int steps;
  final int caloriesBurned;
  final int caloriesIntake;
  final int waterIntake; // ml
  final double? weight;
  final BodyMeasurementsModel? measurements;
  final String? mood;
  final String notes;

  ProgressLogModel({
    required this.id,
    required this.date,
    this.steps = 0,
    this.caloriesBurned = 0,
    this.caloriesIntake = 0,
    this.waterIntake = 0,
    this.weight,
    this.measurements,
    this.mood,
    this.notes = '',
  });

  factory ProgressLogModel.fromJson(Map<String, dynamic> json) {
    return ProgressLogModel(
      id: json['_id'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      steps: json['steps'] ?? 0,
      caloriesBurned: json['caloriesBurned'] ?? 0,
      caloriesIntake: json['caloriesIntake'] ?? 0,
      waterIntake: json['waterIntake'] ?? 0,
      weight: (json['weight'] as num?)?.toDouble(),
      measurements: json['measurements'] != null
          ? BodyMeasurementsModel.fromJson(json['measurements'])
          : null,
      mood: json['mood'],
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'steps': steps,
        'caloriesBurned': caloriesBurned,
        'caloriesIntake': caloriesIntake,
        'waterIntake': waterIntake,
        'weight': weight,
        'mood': mood,
        'notes': notes,
      };
}

/// Body measurements model
class BodyMeasurementsModel {
  final double? chest;
  final double? waist;
  final double? hips;
  final double? bicep;
  final double? thigh;
  final double? calf;

  BodyMeasurementsModel({
    this.chest,
    this.waist,
    this.hips,
    this.bicep,
    this.thigh,
    this.calf,
  });

  factory BodyMeasurementsModel.fromJson(Map<String, dynamic> json) {
    return BodyMeasurementsModel(
      chest: (json['chest'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      bicep: (json['bicep'] as num?)?.toDouble(),
      thigh: (json['thigh'] as num?)?.toDouble(),
      calf: (json['calf'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'chest': chest,
        'waist': waist,
        'hips': hips,
        'bicep': bicep,
        'thigh': thigh,
        'calf': calf,
      };
}
