import 'package:cycle_tracker_app/dependencies.dart';

/// Domain entity representing a family member's profile
class Profile extends Equatable {
  final String id;
  final String name;
  final DateTime? birthDate;
  final String? photoPath;
  final String? colorCode;
  final int defaultCycleLength;
  final int defaultPeriodLength;
  final Map<String, dynamic>? trackingPreferences;
  final Map<String, dynamic>? privacySettings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.name,
    this.birthDate,
    this.photoPath,
    this.colorCode,
    this.defaultCycleLength = 28,
    this.defaultPeriodLength = 5,
    this.trackingPreferences,
    this.privacySettings,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of this profile with optional new values
  Profile copyWith({
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
    return Profile(
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

  @override
  List<Object?> get props => [
        id,
        name,
        birthDate,
        photoPath,
        colorCode,
        defaultCycleLength,
        defaultPeriodLength,
        trackingPreferences,
        privacySettings,
        isActive,
        createdAt,
        updatedAt,
      ];
}
