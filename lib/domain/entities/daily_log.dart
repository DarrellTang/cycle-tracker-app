import 'package:equatable/equatable.dart';

/// Represents a daily log entry for comprehensive daily tracking
class DailyLog extends Equatable {
  const DailyLog({
    required this.id,
    required this.profileId,
    required this.date,
    this.energyLevel,
    this.mood,
    this.moodStability,
    this.stressLevel,
    this.sleepQuality,
    this.appetiteChanges,
    this.socialPreference,
    this.emotionalNeeds,
    this.observations,
    this.customNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String profileId;
  final DateTime date;
  final int? energyLevel; // 1-5 scale
  final MoodType? mood;
  final int? moodStability; // 1-5 scale (1=very unstable, 5=very stable)
  final int? stressLevel; // 1-5 scale
  final int? sleepQuality; // 1-5 scale
  final AppetiteChange? appetiteChanges;
  final SocialPreference? socialPreference;
  final EmotionalNeed? emotionalNeeds;
  final String? observations;
  final String? customNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    profileId,
    date,
    energyLevel,
    mood,
    moodStability,
    stressLevel,
    sleepQuality,
    appetiteChanges,
    socialPreference,
    emotionalNeeds,
    observations,
    customNotes,
    createdAt,
    updatedAt,
  ];

  DailyLog copyWith({
    String? id,
    String? profileId,
    DateTime? date,
    int? energyLevel,
    MoodType? mood,
    int? moodStability,
    int? stressLevel,
    int? sleepQuality,
    AppetiteChange? appetiteChanges,
    SocialPreference? socialPreference,
    EmotionalNeed? emotionalNeeds,
    String? observations,
    String? customNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyLog(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      date: date ?? this.date,
      energyLevel: energyLevel ?? this.energyLevel,
      mood: mood ?? this.mood,
      moodStability: moodStability ?? this.moodStability,
      stressLevel: stressLevel ?? this.stressLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      appetiteChanges: appetiteChanges ?? this.appetiteChanges,
      socialPreference: socialPreference ?? this.socialPreference,
      emotionalNeeds: emotionalNeeds ?? this.emotionalNeeds,
      observations: observations ?? this.observations,
      customNotes: customNotes ?? this.customNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Enumeration of mood types
enum MoodType {
  happy,
  neutral,
  irritable,
  anxious,
  sad,
  angry,
  energetic,
  calm,
  overwhelmed,
  content,
}

extension MoodTypeExtension on MoodType {
  String get displayName {
    switch (this) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.irritable:
        return 'Irritable';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.sad:
        return 'Sad';
      case MoodType.angry:
        return 'Angry';
      case MoodType.energetic:
        return 'Energetic';
      case MoodType.calm:
        return 'Calm';
      case MoodType.overwhelmed:
        return 'Overwhelmed';
      case MoodType.content:
        return 'Content';
    }
  }
}

/// Enumeration of appetite changes
enum AppetiteChange { normal, increased, decreased, cravings, nausea, aversion }

extension AppetiteChangeExtension on AppetiteChange {
  String get displayName {
    switch (this) {
      case AppetiteChange.normal:
        return 'Normal';
      case AppetiteChange.increased:
        return 'Increased';
      case AppetiteChange.decreased:
        return 'Decreased';
      case AppetiteChange.cravings:
        return 'Food Cravings';
      case AppetiteChange.nausea:
        return 'Nausea';
      case AppetiteChange.aversion:
        return 'Food Aversion';
    }
  }
}

/// Enumeration of social preferences
enum SocialPreference {
  outgoing,
  normal,
  withdrawn,
  needsSpace,
  needsCompany,
  mixed,
}

extension SocialPreferenceExtension on SocialPreference {
  String get displayName {
    switch (this) {
      case SocialPreference.outgoing:
        return 'Outgoing';
      case SocialPreference.normal:
        return 'Normal';
      case SocialPreference.withdrawn:
        return 'Withdrawn';
      case SocialPreference.needsSpace:
        return 'Needs Space';
      case SocialPreference.needsCompany:
        return 'Needs Company';
      case SocialPreference.mixed:
        return 'Mixed Feelings';
    }
  }
}

/// Enumeration of emotional needs
enum EmotionalNeed {
  space,
  comfort,
  attention,
  understanding,
  physicalAffection,
  encouragement,
  practicalHelp,
  none,
}

extension EmotionalNeedExtension on EmotionalNeed {
  String get displayName {
    switch (this) {
      case EmotionalNeed.space:
        return 'Space';
      case EmotionalNeed.comfort:
        return 'Comfort';
      case EmotionalNeed.attention:
        return 'Attention';
      case EmotionalNeed.understanding:
        return 'Understanding';
      case EmotionalNeed.physicalAffection:
        return 'Physical Affection';
      case EmotionalNeed.encouragement:
        return 'Encouragement';
      case EmotionalNeed.practicalHelp:
        return 'Practical Help';
      case EmotionalNeed.none:
        return 'None';
    }
  }
}
