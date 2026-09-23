import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static const String _databaseName = 'georemind.db';
  static const int _databaseVersion = 2;

  static const String userTable = 'user_profile';

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
        await db.execute('''
          CREATE TABLE user_profile (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            home_location TEXT,
            onboarding_completed INTEGER DEFAULT 0,
            created_at TEXT
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE user_profile
            ADD COLUMN onboarding_completed INTEGER DEFAULT 0
          ''');
        }
      },
    );
  }

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
}