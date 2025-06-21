import 'package:cycle_tracker_app/domain/entities/profile.dart';

/// Repository interface for profile data operations
abstract class ProfileRepository {
  /// Get all profiles
  Future<List<Profile>> getAllProfiles();

  /// Get a profile by ID
  Future<Profile?> getProfileById(String id);

  /// Create a new profile
  Future<Profile> createProfile(Profile profile);

  /// Update an existing profile
  Future<Profile> updateProfile(Profile profile);

  /// Delete a profile by ID
  Future<void> deleteProfile(String id);

  /// Search profiles by name
  Future<List<Profile>> searchProfiles(String query);
}