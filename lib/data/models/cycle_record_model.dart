import 'package:cycle_tracker_app/domain/entities/cycle_record.dart';

/// Data model for CycleRecord entity with serialization support
class CycleRecordModel extends CycleRecord {
  const CycleRecordModel({
    required super.id,
    required super.profileId,
    required super.startDate,
    super.endDate,
    super.cycleLength,
    super.periodLength,
    required super.currentPhase,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create CycleRecordModel from CycleRecord entity
  factory CycleRecordModel.fromEntity(CycleRecord cycle) {
    return CycleRecordModel(
      id: cycle.id,
      profileId: cycle.profileId,
      startDate: cycle.startDate,
      endDate: cycle.endDate,
      cycleLength: cycle.cycleLength,
      periodLength: cycle.periodLength,
      currentPhase: cycle.currentPhase,
      createdAt: cycle.createdAt,
      updatedAt: cycle.updatedAt,
    );
  }

  /// Create CycleRecordModel from JSON map
  factory CycleRecordModel.fromJson(Map<String, dynamic> json) {
    return CycleRecordModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      cycleLength: json['cycle_length'] as int?,
      periodLength: json['period_length'] as int?,
      currentPhase: CyclePhase.values.firstWhere(
        (phase) => phase.name == json['current_phase'] as String,
        orElse: () => CyclePhase.menstrual,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert CycleRecordModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'cycle_length': cycleLength,
      'period_length': periodLength,
      'current_phase': currentPhase.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to CycleRecord entity
  CycleRecord toEntity() {
    return CycleRecord(
      id: id,
      profileId: profileId,
      startDate: startDate,
      endDate: endDate,
      cycleLength: cycleLength,
      periodLength: periodLength,
      currentPhase: currentPhase,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create a copy with new values
  @override
  CycleRecordModel copyWith({
    String? id,
    String? profileId,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
    int? periodLength,
    CyclePhase? currentPhase,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CycleRecordModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      currentPhase: currentPhase ?? this.currentPhase,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}