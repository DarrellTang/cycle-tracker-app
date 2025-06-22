import 'dart:convert';
import 'package:cycle_tracker_app/domain/entities/phase.dart';

/// Data model for Phase entity with serialization support
class PhaseModel extends Phase {
  const PhaseModel({
    required super.id,
    required super.cycleId,
    required super.phaseType,
    required super.startDay,
    required super.endDay,
    super.duration,
    super.predictions,
    required super.createdAt,
  });

  /// Create PhaseModel from Phase entity
  factory PhaseModel.fromEntity(Phase phase) {
    return PhaseModel(
      id: phase.id,
      cycleId: phase.cycleId,
      phaseType: phase.phaseType,
      startDay: phase.startDay,
      endDay: phase.endDay,
      duration: phase.duration,
      predictions: phase.predictions,
      createdAt: phase.createdAt,
    );
  }

  /// Create PhaseModel from JSON map
  factory PhaseModel.fromJson(Map<String, dynamic> json) {
    return PhaseModel(
      id: json['id'] as String,
      cycleId: json['cycle_id'] as String,
      phaseType: PhaseType.values.firstWhere(
        (type) => type.name == json['phase_type'] as String,
        orElse: () => PhaseType.menstrual,
      ),
      startDay: json['start_day'] as int,
      endDay: json['end_day'] as int,
      duration: json['duration'] as int?,
      predictions: json['predictions'] != null
          ? jsonDecode(json['predictions'] as String) as Map<String, dynamic>
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert PhaseModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cycle_id': cycleId,
      'phase_type': phaseType.name,
      'start_day': startDay,
      'end_day': endDay,
      'duration': duration,
      'predictions': predictions != null ? jsonEncode(predictions) : null,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to Phase entity
  Phase toEntity() {
    return Phase(
      id: id,
      cycleId: cycleId,
      phaseType: phaseType,
      startDay: startDay,
      endDay: endDay,
      duration: duration,
      predictions: predictions,
      createdAt: createdAt,
    );
  }

  /// Create a copy with new values
  @override
  PhaseModel copyWith({
    String? id,
    String? cycleId,
    PhaseType? phaseType,
    int? startDay,
    int? endDay,
    int? duration,
    Map<String, dynamic>? predictions,
    DateTime? createdAt,
  }) {
    return PhaseModel(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      phaseType: phaseType ?? this.phaseType,
      startDay: startDay ?? this.startDay,
      endDay: endDay ?? this.endDay,
      duration: duration ?? this.duration,
      predictions: predictions ?? this.predictions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
