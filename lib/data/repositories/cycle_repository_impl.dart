import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/domain/entities/cycle_record.dart';
import 'package:cycle_tracker_app/domain/repositories/cycle_repository.dart';
import 'package:cycle_tracker_app/data/models/cycle_record_model.dart';
import 'package:cycle_tracker_app/data/datasources/local_database.dart';

/// Implementation of CycleRepository using local SQLite database
class CycleRepositoryImpl implements CycleRepository {
  @override
  Future<List<CycleRecord>> getCyclesByProfileId(String profileId) async {
    final db = await LocalDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.cyclesTable,
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'start_date DESC',
    );

    return maps.map((map) => CycleRecordModel.fromJson(map).toEntity()).toList();
  }

  @override
  Future<CycleRecord?> getLatestCycleByProfileId(String profileId) async {
    final db = await LocalDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.cyclesTable,
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'start_date DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return CycleRecordModel.fromJson(maps.first).toEntity();
  }

  @override
  Future<CycleRecord?> getCycleById(String id) async {
    final db = await LocalDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.cyclesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return CycleRecordModel.fromJson(maps.first).toEntity();
  }

  @override
  Future<CycleRecord> createCycle(CycleRecord cycle) async {
    final db = await LocalDatabase.database;
    final model = CycleRecordModel.fromEntity(cycle);
    
    await db.insert(
      LocalDatabase.cyclesTable,
      model.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return model.toEntity();
  }

  @override
  Future<CycleRecord> updateCycle(CycleRecord cycle) async {
    final db = await LocalDatabase.database;
    final model = CycleRecordModel.fromEntity(cycle.copyWith(
      updatedAt: DateTime.now(),
    ));

    await db.update(
      LocalDatabase.cyclesTable,
      model.toJson(),
      where: 'id = ?',
      whereArgs: [cycle.id],
    );

    return model.toEntity();
  }

  @override
  Future<void> deleteCycle(String id) async {
    final db = await LocalDatabase.database;
    await db.delete(
      LocalDatabase.cyclesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<CycleRecord>> getCyclesInDateRange(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await LocalDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.cyclesTable,
      where: 'profile_id = ? AND start_date >= ? AND start_date <= ?',
      whereArgs: [
        profileId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'start_date DESC',
    );

    return maps.map((map) => CycleRecordModel.fromJson(map).toEntity()).toList();
  }
}