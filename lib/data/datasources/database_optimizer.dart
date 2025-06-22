import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/data/datasources/local_database.dart';

/// Database query optimization utilities
class DatabaseOptimizer {
  /// Analyze query performance and suggest optimizations
  static Future<Map<String, dynamic>> analyzeQueryPerformance() async {
    final db = await LocalDatabase.database;
    final analysis = <String, dynamic>{};

    try {
      // Check index usage
      final indexUsage = await _analyzeIndexUsage(db);
      analysis['index_usage'] = indexUsage;

      // Check table sizes
      final tableSizes = await _getTableSizes(db);
      analysis['table_sizes'] = tableSizes;

      // Check query patterns
      final queryStats = await _getQueryStatistics(db);
      analysis['query_statistics'] = queryStats;

      // Suggest optimizations
      final suggestions = _generateOptimizationSuggestions(
        indexUsage,
        tableSizes,
      );
      analysis['optimization_suggestions'] = suggestions;

      return analysis;
    } catch (e) {
      print('Failed to analyze query performance: $e');
      return {'error': e.toString()};
    }
  }

  /// Analyze index usage across tables
  static Future<Map<String, dynamic>> _analyzeIndexUsage(Database db) async {
    final indexInfo = <String, dynamic>{};

    try {
      // Get all indexes
      final indexes = await db.rawQuery(
        "SELECT name, tbl_name, sql FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'",
      );

      indexInfo['total_indexes'] = indexes.length;
      indexInfo['indexes_by_table'] = <String, List<String>>{};

      for (final index in indexes) {
        final tableName = index['tbl_name'] as String;
        final indexName = index['name'] as String;

        indexInfo['indexes_by_table'][tableName] ??= <String>[];
        (indexInfo['indexes_by_table'][tableName] as List<String>).add(
          indexName,
        );
      }

      return indexInfo;
    } catch (e) {
      return {'error': 'Failed to analyze index usage: $e'};
    }
  }

  /// Get table sizes and row counts
  static Future<Map<String, int>> _getTableSizes(Database db) async {
    final tableSizes = <String, int>{};
    final tables = [
      LocalDatabase.profilesTable,
      LocalDatabase.cyclesTable,
      LocalDatabase.symptomsTable,
      LocalDatabase.dailyLogsTable,
      LocalDatabase.phasesTable,
      LocalDatabase.notificationsTable,
    ];

    for (final tableName in tables) {
      try {
        final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $tableName',
        );
        tableSizes[tableName] = Sqflite.firstIntValue(result) ?? 0;
      } catch (e) {
        tableSizes[tableName] = -1; // Error indicator
      }
    }

    return tableSizes;
  }

  /// Get basic query statistics
  static Future<Map<String, dynamic>> _getQueryStatistics(Database db) async {
    final stats = <String, dynamic>{};

    try {
      // SQLite doesn't provide query statistics by default
      // We'll simulate some basic checks

      // Check for slow queries by testing common operations
      final stopwatch = Stopwatch()..start();

      // Test profile queries
      await db.query(LocalDatabase.profilesTable, limit: 100);
      stats['profile_query_ms'] = stopwatch.elapsedMilliseconds;

      stopwatch.reset();

      // Test cycle queries with joins
      await db.rawQuery('''
        SELECT c.*, COUNT(s.id) as symptom_count 
        FROM ${LocalDatabase.cyclesTable} c 
        LEFT JOIN ${LocalDatabase.symptomsTable} s ON c.profile_id = s.profile_id 
        GROUP BY c.id 
        LIMIT 50
      ''');
      stats['cycle_join_query_ms'] = stopwatch.elapsedMilliseconds;

      stopwatch.stop();

      return stats;
    } catch (e) {
      return {'error': 'Failed to get query statistics: $e'};
    }
  }

  /// Generate optimization suggestions based on analysis
  static List<String> _generateOptimizationSuggestions(
    Map<String, dynamic> indexUsage,
    Map<String, int> tableSizes,
  ) {
    final suggestions = <String>[];

    // Check for large tables without proper indexing
    tableSizes.forEach((tableName, rowCount) {
      if (rowCount > 1000) {
        final tableIndexes =
            indexUsage['indexes_by_table'][tableName] as List<String>?;
        if (tableIndexes == null || tableIndexes.length < 2) {
          suggestions.add(
            'Consider adding more indexes to $tableName ($rowCount rows)',
          );
        }
      }
    });

    // Suggest date-based partitioning for large tables
    if ((tableSizes[LocalDatabase.symptomsTable] ?? 0) > 5000) {
      suggestions.add('Consider archiving old symptom data older than 2 years');
    }

    if ((tableSizes[LocalDatabase.dailyLogsTable] ?? 0) > 5000) {
      suggestions.add('Consider archiving old daily logs older than 2 years');
    }

    // Suggest composite indexes for common query patterns
    suggestions.add(
      'Consider composite index on (profile_id, date) for symptoms table',
    );
    suggestions.add(
      'Consider composite index on (profile_id, start_date) for cycles table',
    );

    return suggestions;
  }

  /// Create additional optimized indexes
  static Future<void> createOptimizedIndexes() async {
    final db = await LocalDatabase.database;

    try {
      await db.transaction((txn) async {
        // Composite indexes for common query patterns
        await txn.execute('''
          CREATE INDEX IF NOT EXISTS idx_symptoms_profile_date_type 
          ON ${LocalDatabase.symptomsTable} (profile_id, date, symptom_type)
        ''');

        await txn.execute('''
          CREATE INDEX IF NOT EXISTS idx_daily_logs_profile_date_energy 
          ON ${LocalDatabase.dailyLogsTable} (profile_id, date, energy_level)
        ''');

        await txn.execute('''
          CREATE INDEX IF NOT EXISTS idx_cycles_profile_start_end 
          ON ${LocalDatabase.cyclesTable} (profile_id, start_date, end_date)
        ''');

        await txn.execute('''
          CREATE INDEX IF NOT EXISTS idx_notifications_profile_type_date 
          ON ${LocalDatabase.notificationsTable} (profile_id, notification_type, scheduled_date)
        ''');

        // Partial indexes for active data
        await txn.execute('''
          CREATE INDEX IF NOT EXISTS idx_profiles_active 
          ON ${LocalDatabase.profilesTable} (is_active) WHERE is_active = 1
        ''');

        await txn.execute('''
          CREATE INDEX IF NOT EXISTS idx_notifications_pending 
          ON ${LocalDatabase.notificationsTable} (scheduled_date) 
          WHERE is_sent = 0 AND is_enabled = 1
        ''');
      });

      print('Optimized indexes created successfully');
    } catch (e) {
      print('Failed to create optimized indexes: $e');
    }
  }

  /// Optimize database by running VACUUM and ANALYZE
  static Future<void> optimizeDatabase() async {
    final db = await LocalDatabase.database;

    try {
      // Update table statistics
      await db.execute('ANALYZE');

      // Rebuild database to reclaim space
      await db.execute('VACUUM');

      // Enable query planner optimizations
      await db.execute('PRAGMA optimize');

      print('Database optimization completed');
    } catch (e) {
      print('Failed to optimize database: $e');
    }
  }

  /// Get optimized query for common use cases
  static String getOptimizedSymptomQuery({
    required String profileId,
    DateTime? startDate,
    DateTime? endDate,
    String? symptomType,
  }) {
    final whereConditions = <String>['profile_id = ?'];
    final whereArgs = <dynamic>[profileId];

    if (startDate != null) {
      whereConditions.add('date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereConditions.add('date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    if (symptomType != null) {
      whereConditions.add('symptom_type = ?');
      whereArgs.add(symptomType);
    }

    return '''
      SELECT * FROM ${LocalDatabase.symptomsTable} 
      WHERE ${whereConditions.join(' AND ')} 
      ORDER BY date DESC, created_at DESC
      LIMIT 1000
    ''';
  }

  /// Get optimized query for cycle analysis
  static String getOptimizedCycleAnalysisQuery(
    String profileId,
    int cyclesToAnalyze,
  ) {
    return '''
      SELECT 
        c.*,
        COUNT(s.id) as symptom_count,
        AVG(dl.energy_level) as avg_energy,
        AVG(dl.mood_stability) as avg_mood_stability
      FROM ${LocalDatabase.cyclesTable} c
      LEFT JOIN ${LocalDatabase.symptomsTable} s ON c.profile_id = s.profile_id 
        AND s.date >= c.start_date 
        AND (c.end_date IS NULL OR s.date <= c.end_date)
      LEFT JOIN ${LocalDatabase.dailyLogsTable} dl ON c.profile_id = dl.profile_id 
        AND dl.date >= c.start_date 
        AND (c.end_date IS NULL OR dl.date <= c.end_date)
      WHERE c.profile_id = ?
      GROUP BY c.id
      ORDER BY c.start_date DESC
      LIMIT ?
    ''';
  }

  /// Archive old data to improve query performance
  static Future<int> archiveOldData({int daysToKeep = 730}) async {
    final db = await LocalDatabase.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    int totalArchived = 0;

    try {
      await db.transaction((txn) async {
        // Archive old symptoms
        final symptomsArchived = await txn.delete(
          LocalDatabase.symptomsTable,
          where: 'date < ?',
          whereArgs: [cutoffDate.toIso8601String()],
        );
        totalArchived += symptomsArchived;

        // Archive old daily logs
        final logsArchived = await txn.delete(
          LocalDatabase.dailyLogsTable,
          where: 'date < ?',
          whereArgs: [cutoffDate.toIso8601String().substring(0, 10)],
        );
        totalArchived += logsArchived;

        // Archive old notifications
        final notificationsArchived = await txn.delete(
          LocalDatabase.notificationsTable,
          where: 'scheduled_date < ? AND is_sent = 1',
          whereArgs: [cutoffDate.toIso8601String()],
        );
        totalArchived += notificationsArchived;

        // Don't archive cycles and phases as they're needed for predictions
      });

      print('Archived $totalArchived old records');
      return totalArchived;
    } catch (e) {
      print('Failed to archive old data: $e');
      return 0;
    }
  }

  /// Configure database for optimal performance
  static Future<void> configureDatabaseSettings() async {
    final db = await LocalDatabase.database;

    try {
      // Enable foreign key constraints
      await db.execute('PRAGMA foreign_keys = ON');

      // Set journal mode to WAL for better concurrent access
      await db.execute('PRAGMA journal_mode = WAL');

      // Set synchronous mode to NORMAL for balance between safety and speed
      await db.execute('PRAGMA synchronous = NORMAL');

      // Set cache size (negative value means KB, positive means pages)
      await db.execute('PRAGMA cache_size = -32000'); // 32MB cache

      // Set temp store to memory for better performance
      await db.execute('PRAGMA temp_store = MEMORY');

      // Enable mmap for better read performance
      await db.execute('PRAGMA mmap_size = 67108864'); // 64MB

      print('Database performance settings configured');
    } catch (e) {
      print('Failed to configure database settings: $e');
    }
  }
}
