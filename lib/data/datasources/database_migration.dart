import 'dart:io';
import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/core/services/encryption_service.dart';
import 'package:cycle_tracker_app/data/datasources/local_database.dart';

/// Database migration system for handling schema changes
class DatabaseMigration {
  /// Current database version
  static const int currentVersion = 1;

  /// Migration scripts for each version upgrade
  static const Map<int, List<String>> migrationScripts = {
    1: [
      // Initial schema - already handled in LocalDatabase._createTables
    ],
    // Future versions would be added here:
    // 2: [
    //   'ALTER TABLE profiles ADD COLUMN new_field TEXT',
    //   'CREATE INDEX idx_new_field ON profiles (new_field)',
    // ],
  };

  /// Execute database migration from old version to new version
  static Future<void> migrate(
    Database db, 
    int oldVersion, 
    int newVersion,
  ) async {
    print('Migrating database from version $oldVersion to $newVersion');
    
    await db.transaction((txn) async {
      for (int version = oldVersion + 1; version <= newVersion; version++) {
        await _executeVersionMigration(txn, version);
      }
    });
    
    print('Database migration completed successfully');
  }

  /// Execute migration for a specific version
  static Future<void> _executeVersionMigration(
    Transaction txn, 
    int version,
  ) async {
    print('Executing migration for version $version');
    
    switch (version) {
      case 1:
        // Initial schema is handled by LocalDatabase._createTables
        break;
        
      case 2:
        await _migrateToVersion2(txn);
        break;
        
      case 3:
        await _migrateToVersion3(txn);
        break;
        
      // Add more version migrations here as needed
      default:
        print('No migration defined for version $version');
    }
  }

  /// Example migration to version 2 (for future use)
  static Future<void> _migrateToVersion2(Transaction txn) async {
    // Example: Add new columns to existing tables
    await txn.execute('''
      ALTER TABLE profiles ADD COLUMN avatar_url TEXT
    ''');
    
    await txn.execute('''
      ALTER TABLE profiles ADD COLUMN timezone TEXT DEFAULT 'UTC'
    ''');
    
    // Create new indexes
    await txn.execute('''
      CREATE INDEX idx_profiles_timezone ON profiles (timezone)
    ''');
    
    print('Migration to version 2 completed');
  }

  /// Example migration to version 3 (for future use)
  static Future<void> _migrateToVersion3(Transaction txn) async {
    // Example: Create new table for user preferences
    await txn.execute('''
      CREATE TABLE user_preferences (
        id TEXT PRIMARY KEY,
        profile_id TEXT NOT NULL,
        preference_key TEXT NOT NULL,
        preference_value TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE,
        UNIQUE(profile_id, preference_key)
      )
    ''');
    
    await txn.execute('''
      CREATE INDEX idx_preferences_profile ON user_preferences (profile_id)
    ''');
    
    print('Migration to version 3 completed');
  }

  /// Backup database before major migrations
  static Future<String?> createBackup() async {
    try {
      final databasesPath = await getDatabasesPath();
      final dbPath = join(databasesPath, 'cycle_tracker.db');
      final backupPath = join(databasesPath, 'cycle_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.db');
      
      // Copy database file
      final dbFile = await File(dbPath).readAsBytes();
      await File(backupPath).writeAsBytes(dbFile);
      
      print('Database backup created at: $backupPath');
      return backupPath;
    } catch (e) {
      print('Failed to create database backup: $e');
      return null;
    }
  }

  /// Restore database from backup
  static Future<bool> restoreFromBackup(String backupPath) async {
    try {
      final databasesPath = await getDatabasesPath();
      final dbPath = join(databasesPath, 'cycle_tracker.db');
      
      // Copy backup file to main database location
      final backupFile = await File(backupPath).readAsBytes();
      await File(dbPath).writeAsBytes(backupFile);
      
      print('Database restored from backup: $backupPath');
      return true;
    } catch (e) {
      print('Failed to restore database from backup: $e');
      return false;
    }
  }

  /// Validate database integrity after migration
  static Future<bool> validateDatabaseIntegrity(Database db) async {
    try {
      // Check if all expected tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
      );
      
      final expectedTables = [
        'profiles',
        'cycles', 
        'symptoms',
        'daily_logs',
        'phases',
        'notifications'
      ];
      
      final existingTableNames = tables.map((t) => t['name'] as String).toSet();
      
      for (final expectedTable in expectedTables) {
        if (!existingTableNames.contains(expectedTable)) {
          print('Missing expected table: $expectedTable');
          return false;
        }
      }
      
      // Check foreign key constraints
      await db.execute('PRAGMA foreign_key_check');
      
      // Check database version
      final version = await db.getVersion();
      if (version != currentVersion) {
        print('Database version mismatch. Expected: $currentVersion, Found: $version');
        return false;
      }
      
      print('Database integrity validation passed');
      return true;
    } catch (e) {
      print('Database integrity validation failed: $e');
      return false;
    }
  }

  /// Migrate encrypted data when encryption keys change
  static Future<void> migrateEncryptedData(Database db) async {
    print('Starting encrypted data migration');
    
    try {
      await db.transaction((txn) async {
        // Re-encrypt all sensitive data with new encryption keys
        final tables = ['profiles', 'cycles', 'symptoms', 'daily_logs', 'notifications'];
        
        for (final tableName in tables) {
          await _reencryptTableData(txn, tableName);
        }
      });
      
      print('Encrypted data migration completed');
    } catch (e) {
      print('Encrypted data migration failed: $e');
      rethrow;
    }
  }

  /// Re-encrypt data in a specific table
  static Future<void> _reencryptTableData(Transaction txn, String tableName) async {
    // Get all rows from table
    final rows = await txn.query(tableName);
    
    for (final row in rows) {
      final id = row['id'] as String;
      
      // Decrypt with old key, encrypt with new key
      // This is a simplified example - in practice, you'd need to handle
      // the key rotation more carefully
      final sensitiveFields = _getSensitiveFieldsForTable(tableName);
      final reencryptedData = <String, dynamic>{};
      
      for (final field in sensitiveFields) {
        if (row.containsKey(field) && row[field] != null) {
          try {
            // Decrypt with current encryption service
            final decrypted = EncryptionService.instance.decryptString(row[field] as String);
            // Re-encrypt with current encryption service
            final reencrypted = EncryptionService.instance.encryptString(decrypted);
            reencryptedData[field] = reencrypted;
          } catch (e) {
            // If decryption fails, data might already be in new format
            print('Skipping re-encryption for $tableName.$field: $e');
          }
        }
      }
      
      if (reencryptedData.isNotEmpty) {
        await txn.update(
          tableName,
          reencryptedData,
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }

  /// Get sensitive fields for a specific table
  static List<String> _getSensitiveFieldsForTable(String tableName) {
    const sensitiveFields = {
      'profiles': ['name', 'tracking_preferences', 'privacy_settings'],
      'cycles': ['notes'],
      'symptoms': ['notes'],
      'daily_logs': ['observations', 'custom_notes'],
      'notifications': ['message'],
    };
    
    return sensitiveFields[tableName] ?? [];
  }

  /// Clean up old backup files (keep only last 5)
  static Future<void> cleanupOldBackups() async {
    try {
      final databasesPath = await getDatabasesPath();
      final directory = Directory(databasesPath);
      
      final backupFiles = directory
          .listSync()
          .where((file) => file.path.contains('cycle_tracker_backup_'))
          .map((file) => File(file.path))
          .toList();
      
      // Sort by creation time (newest first)
      backupFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      // Keep only the 5 most recent backups
      if (backupFiles.length > 5) {
        for (int i = 5; i < backupFiles.length; i++) {
          await backupFiles[i].delete();
          print('Deleted old backup: ${backupFiles[i].path}');
        }
      }
    } catch (e) {
      print('Failed to cleanup old backups: $e');
    }
  }

  /// Export database data for migration between devices
  static Future<Map<String, dynamic>?> exportDatabaseData() async {
    try {
      final db = await LocalDatabase.database;
      final exportData = <String, dynamic>{};
      
      // Export all tables
      final tables = ['profiles', 'cycles', 'symptoms', 'daily_logs', 'phases', 'notifications'];
      
      for (final tableName in tables) {
        final rows = await db.query(tableName);
        
        // Decrypt sensitive data before export
        final decryptedRows = rows.map((row) {
          final sensitiveFields = _getSensitiveFieldsForTable(tableName);
          final decryptedRow = Map<String, dynamic>.from(row);
          
          for (final field in sensitiveFields) {
            if (decryptedRow.containsKey(field) && decryptedRow[field] != null) {
              try {
                decryptedRow[field] = EncryptionService.instance.decryptString(
                  decryptedRow[field] as String
                );
              } catch (e) {
                // Keep original value if decryption fails
              }
            }
          }
          
          return decryptedRow;
        }).toList();
        
        exportData[tableName] = decryptedRows;
      }
      
      exportData['version'] = currentVersion;
      exportData['exported_at'] = DateTime.now().toIso8601String();
      
      return exportData;
    } catch (e) {
      print('Failed to export database data: $e');
      return null;
    }
  }

  /// Import database data from export
  static Future<bool> importDatabaseData(Map<String, dynamic> importData) async {
    try {
      final db = await LocalDatabase.database;
      
      await db.transaction((txn) async {
        // Clear existing data
        final tables = ['notifications', 'phases', 'daily_logs', 'symptoms', 'cycles', 'profiles'];
        for (final tableName in tables) {
          await txn.delete(tableName);
        }
        
        // Import data for each table
        for (final tableName in tables.reversed) {
          if (importData.containsKey(tableName)) {
            final rows = importData[tableName] as List<dynamic>;
            
            for (final row in rows) {
              final rowData = Map<String, dynamic>.from(row as Map);
              
              // Re-encrypt sensitive data
              final sensitiveFields = _getSensitiveFieldsForTable(tableName);
              for (final field in sensitiveFields) {
                if (rowData.containsKey(field) && rowData[field] != null) {
                  rowData[field] = EncryptionService.instance.encryptString(
                    rowData[field] as String
                  );
                }
              }
              
              await txn.insert(tableName, rowData);
            }
          }
        }
      });
      
      print('Database import completed successfully');
      return true;
    } catch (e) {
      print('Failed to import database data: $e');
      return false;
    }
  }
}