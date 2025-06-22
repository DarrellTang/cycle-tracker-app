import 'package:cycle_tracker_app/domain/entities/symptom.dart';

/// Data model for Symptom entity with serialization support
class SymptomModel extends Symptom {
  const SymptomModel({
    required super.id,
    required super.profileId,
    required super.date,
    required super.symptomType,
    super.severity,
    super.notes,
    required super.createdAt,
  });

  /// Create SymptomModel from Symptom entity
  factory SymptomModel.fromEntity(Symptom symptom) {
    return SymptomModel(
      id: symptom.id,
      profileId: symptom.profileId,
      date: symptom.date,
      symptomType: symptom.symptomType,
      severity: symptom.severity,
      notes: symptom.notes,
      createdAt: symptom.createdAt,
    );
  }

  /// Create SymptomModel from JSON map
  factory SymptomModel.fromJson(Map<String, dynamic> json) {
    return SymptomModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      date: DateTime.parse(json['date'] as String),
      symptomType: SymptomType.values.firstWhere(
        (type) => type.name == json['symptom_type'] as String,
        orElse: () => SymptomType.other,
      ),
      severity: json['severity'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert SymptomModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'date': date.toIso8601String(),
      'symptom_type': symptomType.name,
      'severity': severity,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to Symptom entity
  Symptom toEntity() {
    return Symptom(
      id: id,
      profileId: profileId,
      date: date,
      symptomType: symptomType,
      severity: severity,
      notes: notes,
      createdAt: createdAt,
    );
  }

  /// Create a copy with new values
  @override
  SymptomModel copyWith({
    String? id,
    String? profileId,
    DateTime? date,
    SymptomType? symptomType,
    int? severity,
    String? notes,
    DateTime? createdAt,
  }) {
    return SymptomModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      date: date ?? this.date,
      symptomType: symptomType ?? this.symptomType,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
