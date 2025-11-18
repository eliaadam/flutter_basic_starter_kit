//==================================
// user_crud.dart
//==================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

extension UserCRUD on DatabaseHelper {
  Future<void> createUser(Map<String, dynamic> userData, String token) async {
    final db = await database;

    // Make sure we have an api_id
    final apiId = userData['id'];

    final existing = await db.query(
      'users',
      where: 'api_id = ?',
      whereArgs: [apiId],
    );

    final insertData = {
      'api_id': apiId,
      'name': userData['name'] ?? '',
      'email': userData['email'] ?? '',
      'api_token': token,
      'phone_number': userData['phone_number'] ?? '',
      'email_verified_at': userData['email_verified_at'], // can be null
      'created_at': userData['created_at'] ?? DateTime.now().toIso8601String(),
      'updated_at': userData['updated_at'] ?? DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('logged_in_user_api_id', insertData['api_id']);

    if (existing.isEmpty) {
      await db.insert('users', insertData);
    } else {
      await db.update(
        'users',
        insertData,
        where: 'api_id = ?',
        whereArgs: [apiId],
      );
    }
  }

  Future<int?> getLocalUserIdFromApiId(int apiId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'api_id = ?',
      whereArgs: [apiId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first['id'] as int : null;
  }

  Future<int?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final apiId = prefs.getInt('logged_in_user_api_id');
    if (apiId == null) {
      if (kDebugMode) print("No current user API ID in prefs");
      return null;
    }
    final db = await database;
    final res = await db.query(
      'users',
      where: 'api_id = ?',
      whereArgs: [apiId],
      limit: 1,
    );
    if (res.isNotEmpty) return res.first['id'] as int;
    return null;
  }

  Future<Map<String, dynamic>?> getCurrentUserWithSubscription() async {
    final db = await database;
    final userId = await getLoggedInUserId();
    if (userId == null) return null;

    final user = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    final sub = await db.query(
      'subscriptions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'purchase_date DESC',
      limit: 1,
    );

    if (user.isEmpty) return null;
    return {
      'name': user.first['name'],
      'subscription': sub.isNotEmpty
          ? sub.first['subscription_name']
          : 'No Plan',
    };
  }

  Future<void> updateSubscription({
    required String subscriptionName,
    required int durationMonths,
    required double amountPaid,
  }) async {
    final db = await database;
    final userId = await getLoggedInUserId();
    if (userId == null) return;

    final now = DateTime.now();
    final renewDate = DateTime(now.year, now.month + durationMonths, now.day);

    await db.insert('subscriptions', {
      'subscription_name': subscriptionName,
      'purchase_date': now.toIso8601String(),
      'renew_date': renewDate.toIso8601String(),
      'duration_months': durationMonths,
      'amount_paid': amountPaid,
      'user_id': userId,
    });
  }

  Future<Map<String, dynamic>?> getLoggedInUser() async {
    final userId = await getLoggedInUserId();
    if (userId == null) {
      if (kDebugMode) print("No current user logged in");
      return null;
    }

    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (kDebugMode) print("Fetched logged-in user: $result");

    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUser({
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    final db = await database;
    final userId = await getLoggedInUserId();
    if (userId == null) return;

    await db.update(
      'users',
      {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
