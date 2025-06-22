import 'package:equatable/equatable.dart';

/// Represents a symptom entry for tracking physical and emotional symptoms
class Symptom extends Equatable {
  const Symptom({
    required this.id,
    required this.profileId,
    required this.date,
    required this.symptomType,
    this.severity,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String profileId;
  final DateTime date;
  final SymptomType symptomType;
  final int? severity; // 1-5 scale for intensity
  final String? notes;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    profileId,
    date,
    symptomType,
    severity,
    notes,
    createdAt,
  ];

  Symptom copyWith({
    String? id,
    String? profileId,
    DateTime? date,
    SymptomType? symptomType,
    int? severity,
    String? notes,
    DateTime? createdAt,
  }) {
    return Symptom(
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

/// Enumeration of symptom types that can be tracked
enum SymptomType {
  // Physical symptoms
  cramps,
  headache,
  backPain,
  bloating,
  breastTenderness,
  acne,
  fatigue,
  nausea,
  sleepIssues,
  appetiteChanges,

  // Emotional symptoms
  irritability,
  anxiety,
  moodSwings,
  sadness,
  depression,
  sensitivity,
  stressIntolerance,
  socialWithdrawal,

  // Energy and cognitive
  lowEnergy,
  highEnergy,
  brainfog,
  concentration,
  motivation,

  // Other
  other,
}

extension SymptomTypeExtension on SymptomType {
  String get displayName {
    switch (this) {
      case SymptomType.cramps:
        return 'Cramps';
      case SymptomType.headache:
        return 'Headache';
      case SymptomType.backPain:
        return 'Back Pain';
      case SymptomType.bloating:
        return 'Bloating';
      case SymptomType.breastTenderness:
        return 'Breast Tenderness';
      case SymptomType.acne:
        return 'Acne';
      case SymptomType.fatigue:
        return 'Fatigue';
      case SymptomType.nausea:
        return 'Nausea';
      case SymptomType.sleepIssues:
        return 'Sleep Issues';
      case SymptomType.appetiteChanges:
        return 'Appetite Changes';
      case SymptomType.irritability:
        return 'Irritability';
      case SymptomType.anxiety:
        return 'Anxiety';
      case SymptomType.moodSwings:
        return 'Mood Swings';
      case SymptomType.sadness:
        return 'Sadness';
      case SymptomType.depression:
        return 'Depression';
      case SymptomType.sensitivity:
        return 'Emotional Sensitivity';
      case SymptomType.stressIntolerance:
        return 'Stress Intolerance';
      case SymptomType.socialWithdrawal:
        return 'Social Withdrawal';
      case SymptomType.lowEnergy:
        return 'Low Energy';
      case SymptomType.highEnergy:
        return 'High Energy';
      case SymptomType.brainfog:
        return 'Brain Fog';
      case SymptomType.concentration:
        return 'Concentration Issues';
      case SymptomType.motivation:
        return 'Low Motivation';
      case SymptomType.other:
        return 'Other';
    }
  }

  String get category {
    switch (this) {
      case SymptomType.cramps:
      case SymptomType.headache:
      case SymptomType.backPain:
      case SymptomType.bloating:
      case SymptomType.breastTenderness:
      case SymptomType.acne:
      case SymptomType.fatigue:
      case SymptomType.nausea:
      case SymptomType.sleepIssues:
      case SymptomType.appetiteChanges:
        return 'Physical';
      case SymptomType.irritability:
      case SymptomType.anxiety:
      case SymptomType.moodSwings:
      case SymptomType.sadness:
      case SymptomType.depression:
      case SymptomType.sensitivity:
      case SymptomType.stressIntolerance:
      case SymptomType.socialWithdrawal:
        return 'Emotional';
      case SymptomType.lowEnergy:
      case SymptomType.highEnergy:
      case SymptomType.brainfog:
      case SymptomType.concentration:
      case SymptomType.motivation:
        return 'Energy & Cognitive';
      case SymptomType.other:
        return 'Other';
    }
  }
}
