import 'package:cycle_tracker_app/domain/entities/daily_log.dart';

/// Data model for DailyLog entity with serialization support
class DailyLogModel extends DailyLog {
  const DailyLogModel({
    required super.id,
    required super.profileId,
    required super.date,
    super.energyLevel,
    super.mood,
    super.moodStability,
    super.stressLevel,
    super.sleepQuality,
    super.appetiteChanges,
    super.socialPreference,
    super.emotionalNeeds,
    super.observations,
    super.customNotes,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create DailyLogModel from DailyLog entity
  factory DailyLogModel.fromEntity(DailyLog dailyLog) {
    return DailyLogModel(
      id: dailyLog.id,
      profileId: dailyLog.profileId,
      date: dailyLog.date,
      energyLevel: dailyLog.energyLevel,
      mood: dailyLog.mood,
      moodStability: dailyLog.moodStability,
      stressLevel: dailyLog.stressLevel,
      sleepQuality: dailyLog.sleepQuality,
      appetiteChanges: dailyLog.appetiteChanges,
      socialPreference: dailyLog.socialPreference,
      emotionalNeeds: dailyLog.emotionalNeeds,
      observations: dailyLog.observations,
      customNotes: dailyLog.customNotes,
      createdAt: dailyLog.createdAt,
      updatedAt: dailyLog.updatedAt,
    );
  }

  /// Create DailyLogModel from JSON map
  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      date: DateTime.parse(json['date'] as String),
      energyLevel: json['energy_level'] as int?,
      mood: json['mood'] != null
          ? MoodType.values.firstWhere(
              (mood) => mood.name == json['mood'] as String,
              orElse: () => MoodType.neutral,
            )
          : null,
      moodStability: json['mood_stability'] as int?,
      stressLevel: json['stress_level'] as int?,
      sleepQuality: json['sleep_quality'] as int?,
      appetiteChanges: json['appetite_changes'] != null
          ? AppetiteChange.values.firstWhere(
              (change) => change.name == json['appetite_changes'] as String,
              orElse: () => AppetiteChange.normal,
            )
          : null,
      socialPreference: json['social_preference'] != null
          ? SocialPreference.values.firstWhere(
              (pref) => pref.name == json['social_preference'] as String,
              orElse: () => SocialPreference.normal,
            )
          : null,
      emotionalNeeds: json['emotional_needs'] != null
          ? EmotionalNeed.values.firstWhere(
              (need) => need.name == json['emotional_needs'] as String,
              orElse: () => EmotionalNeed.none,
            )
          : null,
      observations: json['observations'] as String?,
      customNotes: json['custom_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert DailyLogModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'date': date.toIso8601String(),
      'energy_level': energyLevel,
      'mood': mood?.name,
      'mood_stability': moodStability,
      'stress_level': stressLevel,
      'sleep_quality': sleepQuality,
      'appetite_changes': appetiteChanges?.name,
      'social_preference': socialPreference?.name,
      'emotional_needs': emotionalNeeds?.name,
      'observations': observations,
      'custom_notes': customNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to DailyLog entity
  DailyLog toEntity() {
    return DailyLog(
      id: id,
      profileId: profileId,
      date: date,
      energyLevel: energyLevel,
      mood: mood,
      moodStability: moodStability,
      stressLevel: stressLevel,
      sleepQuality: sleepQuality,
      appetiteChanges: appetiteChanges,
      socialPreference: socialPreference,
      emotionalNeeds: emotionalNeeds,
      observations: observations,
      customNotes: customNotes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create a copy with new values
  @override
  DailyLogModel copyWith({
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
    return DailyLogModel(
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
