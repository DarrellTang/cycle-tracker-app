import 'dart:convert';
import 'package:cycle_tracker_app/domain/entities/profile.dart';

/// Data model for Profile entity with serialization support
class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.name,
    super.birthDate,
    super.photoPath,
    super.colorCode,
    super.defaultCycleLength = 28,
    super.defaultPeriodLength = 5,
    super.trackingPreferences,
    super.privacySettings,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create ProfileModel from Profile entity
  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      name: profile.name,
      birthDate: profile.birthDate,
      photoPath: profile.photoPath,
      colorCode: profile.colorCode,
      defaultCycleLength: profile.defaultCycleLength,
      defaultPeriodLength: profile.defaultPeriodLength,
      trackingPreferences: profile.trackingPreferences,
      privacySettings: profile.privacySettings,
      isActive: profile.isActive,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  /// Create ProfileModel from JSON map
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      photoPath: json['photo_path'] as String?,
      colorCode: json['color_code'] as String?,
      defaultCycleLength: json['default_cycle_length'] as int? ?? 28,
      defaultPeriodLength: json['default_period_length'] as int? ?? 5,
      trackingPreferences: json['tracking_preferences'] != null
          ? jsonDecode(json['tracking_preferences'] as String) as Map<String, dynamic>
          : null,
      privacySettings: json['privacy_settings'] != null
          ? jsonDecode(json['privacy_settings'] as String) as Map<String, dynamic>
          : null,
      isActive: (json['is_active'] as int?) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert ProfileModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birth_date': birthDate?.toIso8601String(),
      'photo_path': photoPath,
      'color_code': colorCode,
      'default_cycle_length': defaultCycleLength,
      'default_period_length': defaultPeriodLength,
      'tracking_preferences': trackingPreferences != null
          ? jsonEncode(trackingPreferences)
          : null,
      'privacy_settings': privacySettings != null
          ? jsonEncode(privacySettings)
          : null,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to Profile entity
  Profile toEntity() {
    return Profile(
      id: id,
      name: name,
      birthDate: birthDate,
      photoPath: photoPath,
      colorCode: colorCode,
      defaultCycleLength: defaultCycleLength,
      defaultPeriodLength: defaultPeriodLength,
      trackingPreferences: trackingPreferences,
      privacySettings: privacySettings,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create a copy with new values
  @override
  ProfileModel copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? photoPath,
    String? colorCode,
    int? defaultCycleLength,
    int? defaultPeriodLength,
    Map<String, dynamic>? trackingPreferences,
    Map<String, dynamic>? privacySettings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      photoPath: photoPath ?? this.photoPath,
      colorCode: colorCode ?? this.colorCode,
      defaultCycleLength: defaultCycleLength ?? this.defaultCycleLength,
      defaultPeriodLength: defaultPeriodLength ?? this.defaultPeriodLength,
      trackingPreferences: trackingPreferences ?? this.trackingPreferences,
      privacySettings: privacySettings ?? this.privacySettings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
