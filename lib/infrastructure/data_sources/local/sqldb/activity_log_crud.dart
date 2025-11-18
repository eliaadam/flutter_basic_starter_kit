//==================================
// activity_log_crud.dart
//==================================

import 'package:flutter_basic_starter_kit/infrastructure/data_sources/local/sqldb/user_crud.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

extension ActivityLogCRUD on DatabaseHelper {
  Future<List<Map<String, dynamic>>> getActivityLog() async {
    final userId = await getLoggedInUserId();
    if (userId == null) return [];

    final db = await database;
    return await db.query(
      'user_activities',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'time_performed DESC',
    );
  }

  Future<int> insertActivity({
    required String type,
    required String description,
  }) async {
    final userId = await getLoggedInUserId();
    if (userId == null) return 0;

    final db = await database;
    return await db.insert('user_activities', {
      'activity_type': type,
      'activity_description': description,
      'time_performed': DateTime.now().toIso8601String(),
      'user_id': userId,
    });
  }

  Future<int> countActivitiesByType(String type) async {
    final userId = await getLoggedInUserId();
    if (userId == null) return 0;

    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_activities WHERE user_id = ? AND activity_type = ?',
      [userId, type],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getRecentActivities({
    int limit = 5,
  }) async {
    final userId = await getLoggedInUserId();
    if (userId == null) return [];

    final db = await database;
    return await db.query(
      'user_activities',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'time_performed DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getActivitiesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final userId = await getLoggedInUserId();
    if (userId == null) return [];

    final db = await database;
    return await db.query(
      'user_activities',
      where: 'user_id = ? AND time_performed BETWEEN ? AND ?',
      whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'time_performed DESC',
    );
  }
}
