import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService instance = DatabaseService._internal();

  static const String _databaseName = 'georemind.db';
  static const int _databaseVersion = 2;

  Database? _database;

  // ============================================================
  // DATABASE
  // ============================================================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ============================================================
  // CREATE DATABASE
  // ============================================================

  Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    // ------------------------------------------------------------
    // USER PROFILE
    // ------------------------------------------------------------

    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL DEFAULT '',
        home_address TEXT NOT NULL DEFAULT '',
        home_latitude REAL,
        home_longitude REAL,
        home_city TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');

    // ------------------------------------------------------------
    // FREQUENT PLACES
    // ------------------------------------------------------------

    await db.execute('''
      CREATE TABLE places (
        id TEXT PRIMARY KEY,
        icon TEXT NOT NULL,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL,
        longitude REAL
      )
    ''');

    // ------------------------------------------------------------
    // REMINDERS
    // ------------------------------------------------------------

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY,
        task TEXT NOT NULL,
        icon TEXT NOT NULL,
        place TEXT NOT NULL,
        reminder_when TEXT NOT NULL,
        radius INTEGER NOT NULL,
        created TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // ------------------------------------------------------------
    // CHAT HISTORY
    // ------------------------------------------------------------

    await db.execute('''
      CREATE TABLE chat_history (
        id INTEGER PRIMARY KEY,
        icon TEXT NOT NULL,
        title TEXT NOT NULL,
        preview TEXT NOT NULL,
        day TEXT NOT NULL
      )
    ''');
  }

  // ============================================================
  // DATABASE UPGRADE
  // ============================================================

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // ------------------------------------------------------------
    // VERSION 1 → VERSION 2
    // Add new location fields to user_profile
    // ------------------------------------------------------------

    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE user_profile "
        "ADD COLUMN home_address TEXT NOT NULL DEFAULT ''",
      );

      await db.execute(
        "ALTER TABLE user_profile "
        "ADD COLUMN home_latitude REAL",
      );

      await db.execute(
        "ALTER TABLE user_profile "
        "ADD COLUMN home_longitude REAL",
      );

      await db.execute(
        "ALTER TABLE user_profile "
        "ADD COLUMN home_city TEXT NOT NULL DEFAULT ''",
      );
    }
  }

  // ============================================================
  // USER PROFILE
  // ============================================================

  Future<void> saveUserProfile({
    required String name,
    String homeAddress = '',
    double? homeLatitude,
    double? homeLongitude,
    String homeCity = '',
  }) async {
    final db = await database;

    await db.insert(
      'user_profile',
      {
        'id': 1,
        'name': name,
        'home_address': homeAddress,
        'home_latitude': homeLatitude,
        'home_longitude': homeLongitude,
        'home_city': homeCity,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await database;

    final rows = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  // ============================================================
  // PLACES
  // ============================================================

  Future<void> savePlace(Place place) async {
    final db = await database;

    await db.insert(
      'places',
      {
        'id': place.id,
        'icon': place.icon,
        'name': place.name,
        'address': place.addr,
        'latitude': place.latitude,
        'longitude': place.longitude,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Place>> getPlaces() async {
    final db = await database;

    final rows = await db.query(
      'places',
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return rows.map((row) {
      return Place(
        id: row['id'] as String,
        icon: row['icon'] as String,
        name: row['name'] as String,
        addr: row['address'] as String,
        latitude: (row['latitude'] as num?)?.toDouble(),
        longitude: (row['longitude'] as num?)?.toDouble(),
      );
    }).toList();
  }

  Future<void> deletePlace(String id) async {
    final db = await database;

    await db.delete(
      'places',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // REMINDERS
  // ============================================================

  Future<void> saveReminder(Reminder reminder) async {
    final db = await database;

    await db.insert(
      'reminders',
      {
        'id': reminder.id,
        'task': reminder.task,
        'icon': reminder.icon,
        'place': reminder.place,
        'reminder_when': reminder.when,
        'radius': reminder.radius,
        'created': reminder.created,
        'status': reminder.status.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Reminder>> getReminders() async {
    final db = await database;

    final rows = await db.query(
      'reminders',
      orderBy: 'id DESC',
    );

    return rows.map((row) {
      final statusName = row['status'] as String;

      final status = ReminderStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => ReminderStatus.active,
      );

      return Reminder(
        id: row['id'] as int,
        task: row['task'] as String,
        icon: row['icon'] as String,
        place: row['place'] as String,
        when: row['reminder_when'] as String,
        radius: row['radius'] as int,
        created: row['created'] as String,
        status: status,
      );
    }).toList();
  }

  Future<void> updateReminderStatus(
    int id,
    ReminderStatus status,
  ) async {
    final db = await database;

    await db.update(
      'reminders',
      {
        'status': status.name,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteReminder(int id) async {
    final db = await database;

    await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // CHAT HISTORY
  // ============================================================

  Future<void> saveChatEntry(ChatEntry entry) async {
    final db = await database;

    await db.insert(
      'chat_history',
      {
        'id': entry.id,
        'icon': entry.icon,
        'title': entry.title,
        'preview': entry.preview,
        'day': entry.day,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatEntry>> getChatHistory() async {
    final db = await database;

    final rows = await db.query(
      'chat_history',
      orderBy: 'id DESC',
    );

    return rows.map((row) {
      return ChatEntry(
        id: row['id'] as int,
        icon: row['icon'] as String,
        title: row['title'] as String,
        preview: row['preview'] as String,
        day: row['day'] as String,
      );
    }).toList();
  }

  // ============================================================
  // CLEAR USER DATA
  // ============================================================

  Future<void> clearAllData() async {
    final db = await database;

    await db.delete('user_profile');
    await db.delete('places');
    await db.delete('reminders');
    await db.delete('chat_history');
  }

  // ============================================================
  // CLOSE DATABASE
  // ============================================================

  Future<void> close() async {
    if (_database == null) {
      return;
    }

    await _database!.close();
    _database = null;
  }

  // ============================================================
  // DELETE DATABASE
  // ============================================================

  Future<void> deleteDatabaseFile() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await databaseFactory.deleteDatabase(path);
  }
}

final databaseService = DatabaseService.instance;