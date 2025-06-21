import 'package:cycle_tracker_app/dependencies.dart';

/// Domain entity representing a family member's profile
class Profile extends Equatable {
  final String id;
  final String name;
  final DateTime? birthDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.name,
    this.birthDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of this profile with optional new values
  Profile copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, birthDate, createdAt, updatedAt];
}