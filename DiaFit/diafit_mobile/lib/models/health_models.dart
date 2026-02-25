class HealthLog {
  final int? id;
  final int? userId;
  final double bloodSugarLevel;
  final String measurementType;
  final int? stepsCount;
  final int? heartRate;
  final String? notes;
  final DateTime? loggedAt;

  HealthLog({
    this.id,
    this.userId,
    required this.bloodSugarLevel,
    required this.measurementType,
    this.stepsCount,
    this.heartRate,
    this.notes,
    this.loggedAt,
  });

  factory HealthLog.fromJson(Map<String, dynamic> json) => HealthLog(
        id: json['id'],
        userId: json['userId'],
        bloodSugarLevel: (json['bloodSugarLevel'] as num).toDouble(),
        measurementType: json['measurementType'] ?? 'Fasting',
        stepsCount: json['stepsCount'],
        heartRate: json['heartRate'],
        notes: json['notes'],
        loggedAt: json['loggedAt'] != null ? DateTime.parse(json['loggedAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        'bloodSugarLevel': bloodSugarLevel,
        'measurementType': measurementType,
        'stepsCount': stepsCount,
        'heartRate': heartRate,
        'notes': notes,
      };
}

class DietLog {
  final int? id;
  final String foodName;
  final String mealType;
  final double calories;
  final double carbohydratesGrams;
  final double proteinGrams;
  final double fatGrams;
  final String suitabilityResult;
  final String? notes;
  final DateTime? loggedAt;

  DietLog({
    this.id,
    required this.foodName,
    required this.mealType,
    required this.calories,
    required this.carbohydratesGrams,
    required this.proteinGrams,
    required this.fatGrams,
    this.suitabilityResult = 'Unknown',
    this.notes,
    this.loggedAt,
  });

  factory DietLog.fromJson(Map<String, dynamic> json) => DietLog(
        id: json['id'],
        foodName: json['foodName'] ?? '',
        mealType: json['mealType'] ?? 'Lunch',
        calories: (json['calories'] as num).toDouble(),
        carbohydratesGrams: (json['carbohydratesGrams'] as num).toDouble(),
        proteinGrams: (json['proteinGrams'] as num).toDouble(),
        fatGrams: (json['fatGrams'] as num).toDouble(),
        suitabilityResult: json['suitabilityResult'] ?? 'Unknown',
        notes: json['notes'],
        loggedAt: json['loggedAt'] != null ? DateTime.parse(json['loggedAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        'foodName': foodName,
        'mealType': mealType,
        'calories': calories,
        'carbohydratesGrams': carbohydratesGrams,
        'proteinGrams': proteinGrams,
        'fatGrams': fatGrams,
        'suitabilityResult': suitabilityResult,
        'notes': notes,
      };
}

class MedicationLog {
  final int? id;
  final String medicationName;
  final double dosageMg;
  final String frequency;
  final bool isTaken;
  final String? notes;
  final DateTime scheduledAt;
  final DateTime? takenAt;

  MedicationLog({
    this.id,
    required this.medicationName,
    required this.dosageMg,
    required this.frequency,
    this.isTaken = false,
    this.notes,
    required this.scheduledAt,
    this.takenAt,
  });

  factory MedicationLog.fromJson(Map<String, dynamic> json) => MedicationLog(
        id: json['id'],
        medicationName: json['medicationName'] ?? '',
        dosageMg: (json['dosageMg'] as num).toDouble(),
        frequency: json['frequency'] ?? 'Once Daily',
        isTaken: json['isTaken'] ?? false,
        notes: json['notes'],
        scheduledAt: DateTime.parse(json['scheduledAt']),
        takenAt: json['takenAt'] != null ? DateTime.parse(json['takenAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        'medicationName': medicationName,
        'dosageMg': dosageMg,
        'frequency': frequency,
        'notes': notes,
        'scheduledAt': scheduledAt.toIso8601String(),
      };
}
