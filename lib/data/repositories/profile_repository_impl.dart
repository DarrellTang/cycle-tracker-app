import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/domain/entities/profile.dart';
import 'package:cycle_tracker_app/domain/repositories/profile_repository.dart';
import 'package:cycle_tracker_app/data/models/profile_model.dart';
import 'package:cycle_tracker_app/data/datasources/database_helper.dart';

/// Implementation of ProfileRepository using local SQLite database
class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<List<Profile>> getAllProfiles() async {
    final profiles = await DatabaseHelper.getAllProfiles();
    return profiles.map((profile) => profile.toEntity()).toList();
  }

  @override
  Future<Profile?> getProfileById(String id) async {
    final profile = await DatabaseHelper.getProfileById(id);
    return profile?.toEntity();
  }

  @override
  Future<Profile> createProfile(Profile profile) async {
    final model = ProfileModel.fromEntity(profile);
    await DatabaseHelper.insertProfile(model);
    return model.toEntity();
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final model = ProfileModel.fromEntity(
      profile.copyWith(updatedAt: DateTime.now()),
    );
    await DatabaseHelper.updateProfile(model);
    return model.toEntity();
  }

  @override
  Future<void> deleteProfile(String id) async {
    await DatabaseHelper.deleteProfile(id);
  }

  @override
  Future<List<Profile>> searchProfiles(String query) async {
    final profiles = await DatabaseHelper.getAllProfiles();
    final filtered = profiles.where((profile) => 
      profile.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
    return filtered.map((profile) => profile.toEntity()).toList();
  }
}
