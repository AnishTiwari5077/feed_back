// lib/core/database/database_service.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';
import '../models/feedback_model.dart';

/// Dedicated database service layer as required by assignment.
class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), AppConstants.databaseName);
    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.feedbackTable} (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        device_owner TEXT NOT NULL,
        name         TEXT NOT NULL,
        email        TEXT NOT NULL,
        contact      TEXT NOT NULL,
        bug_issue    TEXT NOT NULL,
        user_device  TEXT,
        description  TEXT NOT NULL,
        media_links  TEXT,
        created_at   TEXT NOT NULL
      )
    ''');
  }

  /// Insert a feedback record and return the new row id.
  Future<int> insertFeedback(FeedbackModel feedback) async {
    final db = await database;
    return db.insert(
      AppConstants.feedbackTable,
      feedback.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve all feedback records ordered by newest first.
  Future<List<FeedbackModel>> getAllFeedback() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.feedbackTable,
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => FeedbackModel.fromMap(m)).toList();
  }

  /// Delete a specific feedback   entry by id.
  Future<int> deleteFeedback(int id) async {
    final db = await database;
    return db.delete(
      AppConstants.feedbackTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Close the database connection.
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
