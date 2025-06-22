import 'package:cycle_tracker_app/domain/entities/profile.dart';
import 'package:cycle_tracker_app/domain/repositories/profile_repository.dart';

/// In-memory implementation of ProfileRepository for web fallback
class ProfileRepositoryMemory implements ProfileRepository {
  static final List<Profile> _profiles = [];
  
  @override
  Future<List<Profile>> getAllProfiles() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_profiles);
  }

  @override
  Future<Profile?> getProfileById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _profiles.firstWhere((profile) => profile.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Profile> createProfile(Profile profile) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _profiles.add(profile);
    return profile;
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      _profiles[index] = profile;
    }
    return profile;
  }

  @override
  Future<void> deleteProfile(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _profiles.removeWhere((profile) => profile.id == id);
  }

  @override
  Future<List<Profile>> searchProfiles(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _profiles
        .where((profile) => 
            profile.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}