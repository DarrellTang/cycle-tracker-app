import 'package:cycle_tracker_app/domain/entities/profile.dart';

/// Data model for Profile entity with serialization support
class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.name,
    super.birthDate,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create ProfileModel from Profile entity
  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      name: profile.name,
      birthDate: profile.birthDate,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
