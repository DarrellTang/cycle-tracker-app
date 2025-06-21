import 'package:cycle_tracker_app/dependencies.dart';

/// Domain entity representing a menstrual cycle record
class CycleRecord extends Equatable {
  final String id;
  final String profileId;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength;
  final int? periodLength;
  final CyclePhase currentPhase;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CycleRecord({
    required this.id,
    required this.profileId,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.periodLength,
    required this.currentPhase,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of this cycle record with optional new values
  CycleRecord copyWith({
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
    return CycleRecord(
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

  @override
  List<Object?> get props => [
        id,
        profileId,
        startDate,
        endDate,
        cycleLength,
        periodLength,
        currentPhase,
        createdAt,
        updatedAt,
      ];
}

/// Enum representing different phases of a menstrual cycle
enum CyclePhase {
  menstrual('Menstrual', 'Period phase'),
  follicular('Follicular', 'Follicular phase'),
  ovulation('Ovulation', 'Ovulation phase'),
  luteal('Luteal', 'Luteal phase');

  const CyclePhase(this.displayName, this.description);

  final String displayName;
  final String description;
}