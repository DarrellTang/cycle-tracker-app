import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/data/datasources/local_database.dart';
import 'package:cycle_tracker_app/data/models/profile_model.dart';
import 'package:cycle_tracker_app/data/models/cycle_record_model.dart';
import 'package:cycle_tracker_app/data/models/symptom_model.dart';
import 'package:cycle_tracker_app/data/models/daily_log_model.dart';
import 'package:cycle_tracker_app/data/models/phase_model.dart';
import 'package:cycle_tracker_app/data/models/notification_model.dart';
import 'package:cycle_tracker_app/core/services/encryption_service.dart';

/// Comprehensive database helper for all CRUD operations
class DatabaseHelper {
  /// Get database instance
  static Future<Database> get _database => LocalDatabase.database;

  /// Sensitive fields for each table that should be encrypted
  static const Map<String, List<String>> _sensitiveFields = {
    'profiles': ['name', 'tracking_preferences', 'privacy_settings'],
    'cycles': ['notes'],
    'symptoms': ['notes'],
    'daily_logs': ['observations', 'custom_notes'],
    'notifications': ['message'],
  };

  /// Encrypt sensitive data before storing
  static Map<String, dynamic> _encryptData(String tableName, Map<String, dynamic> data) {
    final sensitiveFields = _sensitiveFields[tableName] ?? [];
    return data.withEncryptedFields(sensitiveFields);
  }

  /// Decrypt sensitive data after reading
  static Map<String, dynamic> _decryptData(String tableName, Map<String, dynamic> data) {
    final sensitiveFields = _sensitiveFields[tableName] ?? [];
    return data.withDecryptedFields(sensitiveFields);
  }

  // ===== PROFILE OPERATIONS =====

  /// Create a new profile
  static Future<void> insertProfile(ProfileModel profile) async {
    final db = await _database;
    final encryptedData = _encryptData('profiles', profile.toJson());
    await db.insert(
      LocalDatabase.profilesTable,
      encryptedData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all profiles
  static Future<List<ProfileModel>> getAllProfiles() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.profilesTable,
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) {
      final decryptedData = _decryptData('profiles', maps[i]);
      return ProfileModel.fromJson(decryptedData);
    });
  }

  /// Get profile by ID
  static Future<ProfileModel?> getProfileById(String id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.profilesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final decryptedData = _decryptData('profiles', maps.first);
      return ProfileModel.fromJson(decryptedData);
    }
    return null;
  }

  /// Update profile
  static Future<void> updateProfile(ProfileModel profile) async {
    final db = await _database;
    final encryptedData = _encryptData('profiles', profile.toJson());
    await db.update(
      LocalDatabase.profilesTable,
      encryptedData,
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  /// Delete profile (soft delete)
  static Future<void> deleteProfile(String id) async {
    final db = await _database;
    await db.update(
      LocalDatabase.profilesTable,
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== CYCLE OPERATIONS =====

  /// Create a new cycle record
  static Future<void> insertCycleRecord(CycleRecordModel cycle) async {
    final db = await _database;
    await db.insert(
      LocalDatabase.cyclesTable,
      cycle.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all cycles for a profile
  static Future<List<CycleRecordModel>> getCyclesByProfileId(String profileId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.cyclesTable,
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'start_date DESC',
    );

    return List.generate(maps.length, (i) {
      return CycleRecordModel.fromJson(maps[i]);
    });
  }

  /// Get current cycle for a profile
  static Future<CycleRecordModel?> getCurrentCycle(String profileId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.cyclesTable,
      where: 'profile_id = ? AND end_date IS NULL',
      whereArgs: [profileId],
      orderBy: 'start_date DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return CycleRecordModel.fromJson(maps.first);
    }
    return null;
  }

  /// Get recent cycles for predictions
  static Future<List<CycleRecordModel>> getRecentCycles(String profileId, int count) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.cyclesTable,
      where: 'profile_id = ? AND end_date IS NOT NULL',
      whereArgs: [profileId],
      orderBy: 'start_date DESC',
      limit: count,
    );

    return List.generate(maps.length, (i) {
      return CycleRecordModel.fromJson(maps[i]);
    });
  }

  /// Update cycle record
  static Future<void> updateCycleRecord(CycleRecordModel cycle) async {
    final db = await _database;
    await db.update(
      LocalDatabase.cyclesTable,
      cycle.toJson(),
      where: 'id = ?',
      whereArgs: [cycle.id],
    );
  }

  /// Delete cycle record
  static Future<void> deleteCycleRecord(String id) async {
    final db = await _database;
    await db.delete(
      LocalDatabase.cyclesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== SYMPTOM OPERATIONS =====

  /// Create a new symptom entry
  static Future<void> insertSymptom(SymptomModel symptom) async {
    final db = await _database;
    await db.insert(
      LocalDatabase.symptomsTable,
      symptom.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get symptoms by profile and date range
  static Future<List<SymptomModel>> getSymptomsByDateRange(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.symptomsTable,
      where: 'profile_id = ? AND date >= ? AND date <= ?',
      whereArgs: [
        profileId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return SymptomModel.fromJson(maps[i]);
    });
  }

  /// Get symptoms for a specific date
  static Future<List<SymptomModel>> getSymptomsForDate(
    String profileId,
    DateTime date,
  ) async {
    final db = await _database;
    final String dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.symptomsTable,
      where: 'profile_id = ? AND date LIKE ?',
      whereArgs: [profileId, '${dateStr.substring(0, 10)}%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return SymptomModel.fromJson(maps[i]);
    });
  }

  /// Delete symptom
  static Future<void> deleteSymptom(String id) async {
    final db = await _database;
    await db.delete(
      LocalDatabase.symptomsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== DAILY LOG OPERATIONS =====

  /// Create or update daily log
  static Future<void> insertOrUpdateDailyLog(DailyLogModel dailyLog) async {
    final db = await _database;
    await db.insert(
      LocalDatabase.dailyLogsTable,
      dailyLog.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get daily log for a specific date
  static Future<DailyLogModel?> getDailyLogForDate(
    String profileId,
    DateTime date,
  ) async {
    final db = await _database;
    final String dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.dailyLogsTable,
      where: 'profile_id = ? AND date = ?',
      whereArgs: [profileId, dateStr.substring(0, 10)],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return DailyLogModel.fromJson(maps.first);
    }
    return null;
  }

  /// Get daily logs by date range
  static Future<List<DailyLogModel>> getDailyLogsByDateRange(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.dailyLogsTable,
      where: 'profile_id = ? AND date >= ? AND date <= ?',
      whereArgs: [
        profileId,
        startDate.toIso8601String().substring(0, 10),
        endDate.toIso8601String().substring(0, 10),
      ],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return DailyLogModel.fromJson(maps[i]);
    });
  }

  /// Delete daily log
  static Future<void> deleteDailyLog(String id) async {
    final db = await _database;
    await db.delete(
      LocalDatabase.dailyLogsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== PHASE OPERATIONS =====

  /// Create phase record
  static Future<void> insertPhase(PhaseModel phase) async {
    final db = await _database;
    await db.insert(
      LocalDatabase.phasesTable,
      phase.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get phases for a cycle
  static Future<List<PhaseModel>> getPhasesByCycleId(String cycleId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.phasesTable,
      where: 'cycle_id = ?',
      whereArgs: [cycleId],
      orderBy: 'start_day ASC',
    );

    return List.generate(maps.length, (i) {
      return PhaseModel.fromJson(maps[i]);
    });
  }

  /// Delete phases for a cycle
  static Future<void> deletePhasesByCycleId(String cycleId) async {
    final db = await _database;
    await db.delete(
      LocalDatabase.phasesTable,
      where: 'cycle_id = ?',
      whereArgs: [cycleId],
    );
  }

  // ===== NOTIFICATION OPERATIONS =====

  /// Create notification
  static Future<void> insertNotification(CycleNotificationModel notification) async {
    final db = await _database;
    await db.insert(
      LocalDatabase.notificationsTable,
      notification.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get pending notifications
  static Future<List<CycleNotificationModel>> getPendingNotifications() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.notificationsTable,
      where: 'is_sent = ? AND is_enabled = ? AND scheduled_date <= ?',
      whereArgs: [0, 1, DateTime.now().toIso8601String()],
      orderBy: 'scheduled_date ASC',
    );

    return List.generate(maps.length, (i) {
      return CycleNotificationModel.fromJson(maps[i]);
    });
  }

  /// Get notifications for a profile
  static Future<List<CycleNotificationModel>> getNotificationsByProfileId(String profileId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      LocalDatabase.notificationsTable,
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'scheduled_date DESC',
    );

    return List.generate(maps.length, (i) {
      return CycleNotificationModel.fromJson(maps[i]);
    });
  }

  /// Mark notification as sent
  static Future<void> markNotificationAsSent(String id) async {
    final db = await _database;
    await db.update(
      LocalDatabase.notificationsTable,
      {'is_sent': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete notification
  static Future<void> deleteNotification(String id) async {
    final db = await _database;
    await db.delete(
      LocalDatabase.notificationsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== UTILITY OPERATIONS =====

  /// Get database statistics
  static Future<Map<String, int>> getDatabaseStats() async {
    final db = await _database;
    
    final profileCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${LocalDatabase.profilesTable} WHERE is_active = 1'),
    ) ?? 0;
    
    final cycleCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${LocalDatabase.cyclesTable}'),
    ) ?? 0;
    
    final symptomCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${LocalDatabase.symptomsTable}'),
    ) ?? 0;
    
    final dailyLogCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${LocalDatabase.dailyLogsTable}'),
    ) ?? 0;

    return {
      'profiles': profileCount,
      'cycles': cycleCount,
      'symptoms': symptomCount,
      'dailyLogs': dailyLogCount,
    };
  }

  /// Clear all data for a profile
  static Future<void> clearProfileData(String profileId) async {
    final db = await _database;
    
    await db.transaction((txn) async {
      // Delete daily logs
      await txn.delete(
        LocalDatabase.dailyLogsTable,
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );
      
      // Delete symptoms
      await txn.delete(
        LocalDatabase.symptomsTable,
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );
      
      // Delete notifications
      await txn.delete(
        LocalDatabase.notificationsTable,
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );
      
      // Delete phases for cycles
      await txn.rawDelete('''
        DELETE FROM ${LocalDatabase.phasesTable} 
        WHERE cycle_id IN (
          SELECT id FROM ${LocalDatabase.cyclesTable} 
          WHERE profile_id = ?
        )
      ''', [profileId]);
      
      // Delete cycles
      await txn.delete(
        LocalDatabase.cyclesTable,
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );
    });
  }
}