import 'package:equatable/equatable.dart';

/// Represents a specific phase within a menstrual cycle
class Phase extends Equatable {
  const Phase({
    required this.id,
    required this.cycleId,
    required this.phaseType,
    required this.startDay,
    required this.endDay,
    this.duration,
    this.predictions,
    required this.createdAt,
  });

  final String id;
  final String cycleId;
  final PhaseType phaseType;
  final int startDay; // Day of cycle (1-based)
  final int endDay; // Day of cycle (1-based)
  final int? duration; // Duration in days
  final Map<String, dynamic>? predictions; // JSON predictions for this phase
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        cycleId,
        phaseType,
        startDay,
        endDay,
        duration,
        predictions,
        createdAt,
      ];

  Phase copyWith({
    String? id,
    String? cycleId,
    PhaseType? phaseType,
    int? startDay,
    int? endDay,
    int? duration,
    Map<String, dynamic>? predictions,
    DateTime? createdAt,
  }) {
    return Phase(
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

/// Enumeration of menstrual cycle phases
enum PhaseType {
  menstrual,
  follicular,
  ovulation,
  luteal,
}

extension PhaseTypeExtension on PhaseType {
  String get displayName {
    switch (this) {
      case PhaseType.menstrual:
        return 'Menstrual';
      case PhaseType.follicular:
        return 'Follicular';
      case PhaseType.ovulation:
        return 'Ovulation';
      case PhaseType.luteal:
        return 'Luteal';
    }
  }

  String get description {
    switch (this) {
      case PhaseType.menstrual:
        return 'Days 1-5: Period bleeding phase';
      case PhaseType.follicular:
        return 'Days 1-13: Pre-ovulation phase';
      case PhaseType.ovulation:
        return 'Days 14-16: Egg release phase';
      case PhaseType.luteal:
        return 'Days 17-28: Post-ovulation phase';
    }
  }

  List<String> get commonSymptoms {
    switch (this) {
      case PhaseType.menstrual:
        return [
          'Cramps',
          'Fatigue',
          'Headaches',
          'Bloating',
          'Back pain',
          'Irritability',
          'Emotional sensitivity'
        ];
      case PhaseType.follicular:
        return [
          'Increasing energy',
          'Clearer skin',
          'Improved sleep',
          'Optimism',
          'Motivation',
          'Creativity'
        ];
      case PhaseType.ovulation:
        return [
          'Mild cramping',
          'Increased temperature',
          'Confidence',
          'Assertiveness',
          'High energy',
          'Social'
        ];
      case PhaseType.luteal:
        return [
          'Breast tenderness',
          'Bloating',
          'Acne',
          'Fatigue',
          'Anxiety',
          'Mood swings',
          'Food cravings'
        ];
    }
  }

  List<String> get supportSuggestions {
    switch (this) {
      case PhaseType.menstrual:
        return [
          'Offer comfort foods and drinks',
          'Suggest rest periods',
          'Be patient with irritability',
          'Provide heating pads',
          'Reduce social expectations'
        ];
      case PhaseType.follicular:
        return [
          'Encourage new projects',
          'Plan social activities',
          'Support creative endeavors',
          'Schedule important conversations',
          'Plan physical activities'
        ];
      case PhaseType.ovulation:
        return [
          'Great time for important decisions',
          'Encourage social interactions',
          'Support confident choices',
          'Plan date nights',
          'Encourage physical activity'
        ];
      case PhaseType.luteal:
        return [
          'Be patient with mood changes',
          'Avoid major decisions',
          'Offer comfort foods',
          'Plan quiet activities',
          'Provide emotional support'
        ];
    }
  }
}