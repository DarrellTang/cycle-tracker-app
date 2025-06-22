import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:cycle_tracker_app/domain/entities/profile.dart';
import 'package:cycle_tracker_app/domain/repositories/profile_repository.dart';
import 'package:cycle_tracker_app/data/repositories/profile_repository_impl.dart';
import 'package:cycle_tracker_app/data/repositories/profile_repository_memory.dart';

/// High-level service for profile management operations
class ProfileService {
  late final ProfileRepository _profileRepository;
  final Uuid _uuid = const Uuid();

  ProfileService() {
    // Use memory storage for web until SQLite issues are resolved
    if (kIsWeb) {
      _profileRepository = ProfileRepositoryMemory();
      dev.log(
        'Using in-memory profile storage for web',
        name: 'ProfileService',
      );
    } else {
      _profileRepository = ProfileRepositoryImpl();
      dev.log(
        'Using SQLite profile storage for mobile',
        name: 'ProfileService',
      );
    }
  }

  /// Get all profiles
  Future<List<Profile>> getAllProfiles() async {
    try {
      dev.log(
        'ProfileService: Getting all profiles...',
        name: 'ProfileService',
      );
      final profiles = await _profileRepository.getAllProfiles();
      dev.log(
        'ProfileService: Retrieved ${profiles.length} profiles',
        name: 'ProfileService',
      );
      return profiles;
    } catch (e) {
      dev.log(
        'Failed to get all profiles: $e',
        name: 'ProfileService',
        error: e,
      );
      rethrow;
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

      dev.log(
        'Profile deleted successfully: $profileId',
        name: 'ProfileService',
      );
    } catch (e) {
      dev.log('Failed to delete profile: $e', name: 'ProfileService');
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
}
