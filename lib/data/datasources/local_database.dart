import 'package:cycle_tracker_app/dependencies.dart';

/// Local SQLite database for storing cycle tracking data
class LocalDatabase {
  static Database? _database;
  static const String _databaseName = 'cycle_tracker.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String profilesTable = 'profiles';
  static const String cyclesTable = 'cycles';

  /// Get the database instance (singleton)
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  static Future<void> _createTables(Database db, int version) async {
    // Create profiles table
    await db.execute('''
      CREATE TABLE $profilesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        birth_date TEXT,
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
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
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
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema migrations here in future versions
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