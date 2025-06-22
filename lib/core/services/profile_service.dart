import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:cycle_tracker_app/domain/entities/profile.dart';
import 'package:cycle_tracker_app/domain/repositories/profile_repository.dart';
import 'package:cycle_tracker_app/data/repositories/profile_repository_impl.dart';

/// High-level service for profile management operations
class ProfileService {
  static const String _activeProfileKey = 'active_profile_id';

  final ProfileRepository _profileRepository = ProfileRepositoryImpl();
  final Uuid _uuid = const Uuid();

  /// Get all profiles
  Future<List<Profile>> getAllProfiles() async {
    try {
      return await _profileRepository.getAllProfiles();
    } catch (e) {
      dev.log('Failed to get all profiles: $e', name: 'ProfileService');
      rethrow;
    }
  }

  /// Get active profile
  Future<Profile?> getActiveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeId = prefs.getString(_activeProfileKey);

      if (activeId == null) return null;

      return await _profileRepository.getProfileById(activeId);
    } catch (e) {
      dev.log('Failed to get active profile: $e', name: 'ProfileService');
      return null;
    }
  }

  /// Get profile by ID
  Future<Profile?> getProfileById(String id) async {
    try {
      return await _profileRepository.getProfileById(id);
    } catch (e) {
      dev.log('Failed to get profile by ID: $e', name: 'ProfileService');
      return null;
    }
  }

  /// Create new profile
  Future<Profile> createProfile({
    required String name,
    DateTime? birthDate,
    String? photoPath,
    String? colorCode,
    int? defaultCycleLength,
    int? defaultPeriodLength,
    Map<String, dynamic>? trackingPreferences,
    Map<String, dynamic>? privacySettings,
  }) async {
    try {
      final now = DateTime.now();
      final newProfile = Profile(
        id: _uuid.v4(),
        name: name,
        birthDate: birthDate,
        photoPath: photoPath,
        colorCode: colorCode,
        defaultCycleLength: defaultCycleLength ?? 28,
        defaultPeriodLength: defaultPeriodLength ?? 5,
        trackingPreferences: trackingPreferences,
        privacySettings: privacySettings,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final createdProfile = await _profileRepository.createProfile(newProfile);

      // If this is the first profile, make it active
      final allProfiles = await getAllProfiles();
      if (allProfiles.length == 1) {
        await setActiveProfile(createdProfile.id);
      }

      dev.log(
        'Profile created successfully: ${createdProfile.name}',
        name: 'ProfileService',
      );
      return createdProfile;
    } catch (e) {
      dev.log('Failed to create profile: $e', name: 'ProfileService');
      rethrow;
    }
  }

  /// Update profile
  Future<Profile> updateProfile(Profile profile) async {
    try {
      final updatedProfile = await _profileRepository.updateProfile(profile);
      dev.log(
        'Profile updated successfully: ${updatedProfile.name}',
        name: 'ProfileService',
      );
      return updatedProfile;
    } catch (e) {
      dev.log('Failed to update profile: $e', name: 'ProfileService');
      rethrow;
    }
  }

  /// Delete profile
  Future<void> deleteProfile(String profileId) async {
    try {
      await _profileRepository.deleteProfile(profileId);

      // If active profile was deleted, set a new active profile
      final prefs = await SharedPreferences.getInstance();
      final activeId = prefs.getString(_activeProfileKey);

      if (activeId == profileId) {
        final remainingProfiles = await getAllProfiles();
        if (remainingProfiles.isNotEmpty) {
          await setActiveProfile(remainingProfiles.first.id);
        } else {
          await prefs.remove(_activeProfileKey);
        }
      }

      dev.log(
        'Profile deleted successfully: $profileId',
        name: 'ProfileService',
      );
    } catch (e) {
      dev.log('Failed to delete profile: $e', name: 'ProfileService');
      rethrow;
    }
  }

  /// Set active profile
  Future<void> setActiveProfile(String profileId) async {
    try {
      // Verify profile exists
      final profile = await _profileRepository.getProfileById(profileId);
      if (profile == null) {
        throw Exception('Profile not found: $profileId');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeProfileKey, profileId);

      dev.log('Active profile set: ${profile.name}', name: 'ProfileService');
    } catch (e) {
      dev.log('Failed to set active profile: $e', name: 'ProfileService');
      rethrow;
    }
  }

  /// Search profiles by name
  Future<List<Profile>> searchProfiles(String query) async {
    try {
      return await _profileRepository.searchProfiles(query);
    } catch (e) {
      dev.log('Failed to search profiles: $e', name: 'ProfileService');
      return [];
    }
  }

  /// Check if profile is active
  Future<bool> isActiveProfile(String profileId) async {
    try {
      final activeProfile = await getActiveProfile();
      return activeProfile?.id == profileId;
    } catch (e) {
      dev.log(
        'Failed to check if profile is active: $e',
        name: 'ProfileService',
      );
      return false;
    }
  }

  /// Get profile count
  Future<int> getProfileCount() async {
    try {
      final profiles = await getAllProfiles();
      return profiles.length;
    } catch (e) {
      dev.log('Failed to get profile count: $e', name: 'ProfileService');
      return 0;
    }
  }

  /// Deactivate profile (set as inactive but don't delete)
  Future<Profile> deactivateProfile(String profileId) async {
    try {
      final profile = await _profileRepository.getProfileById(profileId);
      if (profile == null) {
        throw Exception('Profile not found: $profileId');
      }

      final deactivatedProfile = profile.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );

      return await updateProfile(deactivatedProfile);
    } catch (e) {
      dev.log('Failed to deactivate profile: $e', name: 'ProfileService');
      rethrow;
    }
  }

  /// Reactivate profile
  Future<Profile> reactivateProfile(String profileId) async {
    try {
      final profile = await _profileRepository.getProfileById(profileId);
      if (profile == null) {
        throw Exception('Profile not found: $profileId');
      }

      final reactivatedProfile = profile.copyWith(
        isActive: true,
        updatedAt: DateTime.now(),
      );

      return await updateProfile(reactivatedProfile);
    } catch (e) {
      dev.log('Failed to reactivate profile: $e', name: 'ProfileService');
      rethrow;
    }
  }

  /// Get only active profiles
  Future<List<Profile>> getActiveProfiles() async {
    try {
      final allProfiles = await getAllProfiles();
      return allProfiles.where((profile) => profile.isActive).toList();
    } catch (e) {
      dev.log('Failed to get active profiles: $e', name: 'ProfileService');
      return [];
    }
  }

  /// Clear active profile (for logout scenarios)
  Future<void> clearActiveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeProfileKey);
      dev.log('Active profile cleared', name: 'ProfileService');
    } catch (e) {
      dev.log('Failed to clear active profile: $e', name: 'ProfileService');
    }
  }
}
