import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/core/services/encryption_service.dart';
import 'package:cycle_tracker_app/data/datasources/database_migration.dart';
import 'package:cycle_tracker_app/data/datasources/database_optimizer.dart';

/// Local SQLite database for storing cycle tracking data
class LocalDatabase {
  static Database? _database;
  static const String _databaseName = 'cycle_tracker.db';
  static const int _databaseVersion = DatabaseMigration.currentVersion;

  // Table names
  static const String profilesTable = 'profiles';
  static const String cyclesTable = 'cycles';
  static const String symptomsTable = 'symptoms';
  static const String dailyLogsTable = 'daily_logs';
  static const String phasesTable = 'phases';
  static const String notificationsTable = 'notifications';

  /// Get the database instance (singleton)
  static Future<Database> get database async {
    if (_database == null) {
      // Initialize encryption service first
      await EncryptionService.instance.initialize();
      _database = await _initDatabase();
    }
    return _database!;
  }

  /// Initialize the database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    final database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );

    return database;
  }

  /// Create database tables
  static Future<void> _createTables(Database db, int version) async {
    // Create profiles table
    await db.execute('''
      CREATE TABLE $profilesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        birth_date TEXT,
        photo_path TEXT,
        color_code TEXT,
        default_cycle_length INTEGER DEFAULT 28,
        default_period_length INTEGER DEFAULT 5,
        tracking_preferences TEXT,
        privacy_settings TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create cycles table
    await db.execute('''
      CREATE TABLE $cyclesTable (
        id TEXT PRIMARY KEY,
        profile_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        cycle_length INTEGER,
        period_length INTEGER,
        current_phase TEXT NOT NULL,
        notes TEXT,
        is_predicted INTEGER DEFAULT 0,
        flow_intensity INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES $profilesTable (id) ON DELETE CASCADE
      )
    ''');

    // Create symptoms table
    await db.execute('''
      CREATE TABLE $symptomsTable (
        id TEXT PRIMARY KEY,
        profile_id TEXT NOT NULL,
        date TEXT NOT NULL,
        symptom_type TEXT NOT NULL,
        severity INTEGER,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES $profilesTable (id) ON DELETE CASCADE
      )
    ''');

    // Create daily logs table
    await db.execute('''
      CREATE TABLE $dailyLogsTable (
        id TEXT PRIMARY KEY,
        profile_id TEXT NOT NULL,
        date TEXT NOT NULL,
        energy_level INTEGER,
        mood TEXT,
        mood_stability INTEGER,
        stress_level INTEGER,
        sleep_quality INTEGER,
        appetite_changes TEXT,
        social_preference TEXT,
        emotional_needs TEXT,
        observations TEXT,
        custom_notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES $profilesTable (id) ON DELETE CASCADE,
        UNIQUE(profile_id, date)
      )
    ''');

    // Create phases table for cycle phase details
    await db.execute('''
      CREATE TABLE $phasesTable (
        id TEXT PRIMARY KEY,
        cycle_id TEXT NOT NULL,
        phase_type TEXT NOT NULL,
        start_day INTEGER NOT NULL,
        end_day INTEGER NOT NULL,
        duration INTEGER,
        predictions TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (cycle_id) REFERENCES $cyclesTable (id) ON DELETE CASCADE
      )
    ''');

    // Create notifications table
    await db.execute('''
      CREATE TABLE $notificationsTable (
        id TEXT PRIMARY KEY,
        profile_id TEXT NOT NULL,
        notification_type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        scheduled_date TEXT NOT NULL,
        is_sent INTEGER DEFAULT 0,
        is_enabled INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES $profilesTable (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_cycles_profile_id ON $cyclesTable (profile_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_cycles_start_date ON $cyclesTable (start_date)
    ''');

    await db.execute('''
      CREATE INDEX idx_symptoms_profile_date ON $symptomsTable (profile_id, date)
    ''');

    await db.execute('''
      CREATE INDEX idx_daily_logs_profile_date ON $dailyLogsTable (profile_id, date)
    ''');

    await db.execute('''
      CREATE INDEX idx_phases_cycle_id ON $phasesTable (cycle_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_notifications_profile_date ON $notificationsTable (profile_id, scheduled_date)
    ''');
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Create backup before migration
    await DatabaseMigration.createBackup();

    // Execute migration
    await DatabaseMigration.migrate(db, oldVersion, newVersion);

    // Validate database integrity after migration
    final isValid = await DatabaseMigration.validateDatabaseIntegrity(db);
    if (!isValid) {
      throw Exception('Database migration failed validation');
    }

    // Cleanup old backups
    await DatabaseMigration.cleanupOldBackups();
  }

  /// Configure database when opened
  static Future<void> _onOpen(Database db) async {
    // Configure performance settings
    await DatabaseOptimizer.configureDatabaseSettings();

    // Create optimized indexes
    await DatabaseOptimizer.createOptimizedIndexes();
  }

  /// Close the database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Delete the database (for testing purposes)
  static Future<void> deleteDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    await deleteDatabase(path);
    _database = null;
  }
}
