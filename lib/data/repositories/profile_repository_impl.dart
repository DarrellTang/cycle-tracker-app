import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/domain/entities/profile.dart';
import 'package:cycle_tracker_app/domain/repositories/profile_repository.dart';
import 'package:cycle_tracker_app/data/models/profile_model.dart';
import 'package:cycle_tracker_app/data/datasources/local_database.dart';

/// Implementation of ProfileRepository using local SQLite database
class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<List<Profile>> getAllProfiles() async {
    final db = await LocalDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.profilesTable,
      orderBy: 'name ASC',
    );

    return maps.map((map) => ProfileModel.fromJson(map).toEntity()).toList();
  }

  @override
  Future<Profile?> getProfileById(String id) async {
    final db = await LocalDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.profilesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return ProfileModel.fromJson(maps.first).toEntity();
  }

  @override
  Future<Profile> createProfile(Profile profile) async {
    final db = await LocalDatabase.database;
    final model = ProfileModel.fromEntity(profile);

    await db.insert(
      LocalDatabase.profilesTable,
      model.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return model.toEntity();
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final db = await LocalDatabase.database;
    final model = ProfileModel.fromEntity(
      profile.copyWith(updatedAt: DateTime.now()),
    );

    await db.update(
      LocalDatabase.profilesTable,
      model.toJson(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );

    return model.toEntity();
  }

  @override
  Future<void> deleteProfile(String id) async {
    final db = await LocalDatabase.database;
    await db.delete(
      LocalDatabase.profilesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Profile>> searchProfiles(String query) async {
    final db = await LocalDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.profilesTable,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );

    return maps.map((map) => ProfileModel.fromJson(map).toEntity()).toList();
  }
}
