import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/checkin_record.dart';

class UserProfile {
  final String studentId;
  final String name;

  UserProfile({required this.studentId, required this.name});

  Map<String, dynamic> toMap() => {'studentId': studentId, 'name': name};

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        studentId: map['studentId'] as String,
        name: map['name'] as String,
      );
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        'smart_class.db',
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    } else {
      String path = join(await getDatabasesPath(), 'smart_class.db');
      return await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        studentId TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE checkin_records (
        id TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        checkInTime TEXT NOT NULL,
        checkInLatitude REAL NOT NULL,
        checkInLongitude REAL NOT NULL,
        qrCodeData TEXT NOT NULL,
        previousTopic TEXT NOT NULL,
        expectedTopic TEXT NOT NULL,
        moodBefore INTEGER NOT NULL,
        checkOutTime TEXT,
        checkOutLatitude REAL,
        checkOutLongitude REAL,
        qrCodeDataOut TEXT,
        learnedToday TEXT,
        understandingRating INTEGER,
        feedback TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          studentId TEXT PRIMARY KEY,
          name TEXT NOT NULL
        )
      ''');
    }
  }

  // Insert a new check-in record
  Future<void> insertCheckIn(CheckInRecord record) async {
    final db = await database;
    await db.insert(
      'checkin_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update record with check-out data
  Future<void> updateCheckOut(CheckInRecord record) async {
    final db = await database;
    await db.update(
      'checkin_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Get all records for a specific student
  Future<List<CheckInRecord>> getAllRecords(String studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'checkin_records',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'checkInTime DESC',
    );
    return List.generate(maps.length, (i) => CheckInRecord.fromMap(maps[i]));
  }

  // Get the latest active (non-completed) record for a specific student
  Future<CheckInRecord?> getActiveCheckIn(String studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'checkin_records',
      where: 'studentId = ? AND checkOutTime IS NULL',
      whereArgs: [studentId],
      orderBy: 'checkInTime DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CheckInRecord.fromMap(maps.first);
  }

  // Get record by ID
  Future<CheckInRecord?> getRecordById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'checkin_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CheckInRecord.fromMap(maps.first);
  }

  // Delete a record
  Future<void> deleteRecord(String id) async {
    final db = await database;
    await db.delete(
      'checkin_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get today's records for a specific student
  Future<List<CheckInRecord>> getTodayRecords(String studentId) async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    final tomorrow = DateTime(now.year, now.month, now.day + 1).toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'checkin_records',
      where: 'studentId = ? AND checkInTime >= ? AND checkInTime < ?',
      whereArgs: [studentId, today, tomorrow],
      orderBy: 'checkInTime DESC',
    );
    return List.generate(maps.length, (i) => CheckInRecord.fromMap(maps[i]));
  }

  // User management
  Future<void> saveUser(UserProfile user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getUser(String studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }
}
