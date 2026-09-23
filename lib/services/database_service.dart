import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static const String _databaseName = 'georemind.db';
  static const int _databaseVersion = 3;

  static const String userTable = 'user_profile';
  static const String frequentPlacesTable = 'frequent_places';

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      _databaseName,
    );

    return openDatabase(
      path,
      version: _databaseVersion,

      onCreate: (db, version) async {
        // User profile table
        await db.execute('''
          CREATE TABLE user_profile (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            home_location TEXT,
            onboarding_completed INTEGER DEFAULT 0,
            created_at TEXT
          )
        ''');

        // Frequent places table
        await db.execute('''
          CREATE TABLE frequent_places (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            address TEXT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            place_type TEXT,
            radius REAL NOT NULL DEFAULT 100,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        // Version 1 → Version 2
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE user_profile
            ADD COLUMN onboarding_completed INTEGER DEFAULT 0
          ''');
        }

        // Version 2 → Version 3
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE frequent_places (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              address TEXT,
              latitude REAL NOT NULL,
              longitude REAL NOT NULL,
              place_type TEXT,
              radius REAL NOT NULL DEFAULT 100,
              is_active INTEGER NOT NULL DEFAULT 1,
              created_at TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  // ============================================================
  // USER PROFILE
  // ============================================================

  static Future<void> saveUserName(
    String name,
  ) async {
    final db = await database;

    await db.insert(
      userTable,
      {
        'id': 1,
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getUserName() async {
    final db = await database;

    final result = await db.query(
      userTable,
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first['name'] as String?;
  }

  static Future<void> setOnboardingCompleted() async {
    final db = await database;

    await db.update(
      userTable,
      {
        'onboarding_completed': 1,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  static Future<bool> isOnboardingCompleted() async {
    final db = await database;

    final result = await db.query(
      userTable,
      columns: ['onboarding_completed'],
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      return false;
    }

    return result.first['onboarding_completed'] == 1;
  }

  // ============================================================
  // FREQUENT PLACES
  // ============================================================

  static Future<int> saveFrequentPlace({
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    String? placeType,
    double radius = 100,
  }) async {
    final db = await database;

    return await db.insert(
      frequentPlacesTable,
      {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'place_type': placeType,
        'radius': radius,
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getFrequentPlaces() async {
    final db = await database;

    return await db.query(
      frequentPlacesTable,
      orderBy: 'created_at DESC',
    );
  }

  static Future<Map<String, dynamic>?> getFrequentPlace(
    int id,
  ) async {
    final db = await database;

    final result = await db.query(
      frequentPlacesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  static Future<int> updateFrequentPlace({
    required int id,
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    String? placeType,
    double radius = 100,
  }) async {
    final db = await database;

    return await db.update(
      frequentPlacesTable,
      {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'place_type': placeType,
        'radius': radius,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteFrequentPlace(
    int id,
  ) async {
    final db = await database;

    return await db.delete(
      frequentPlacesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}