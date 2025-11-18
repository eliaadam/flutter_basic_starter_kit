//==================================
// database_helper.dart
//==================================

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_schema.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    debugPrint('✅ Database initialized at: $path');
    return _database!;
  }

  // Initialize and open database
  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 4, // Incremented version for schema updates
      onConfigure: (db) async {
        // Ensure SQLite enforces foreign key relationships
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create all tables on first install
  Future<void> _onCreate(Database db, int version) async {
    print('🚀 Creating database tables...');
    for (final table in createTables) {
      await db.execute(table);
    }
    print('✅ Database tables created successfully.');
  }

  // Handle schema migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('⚙️ Upgrading database from v$oldVersion to v$newVersion...');

    // Simple strategy for now: ensure all tables exist
    // (Future versions can apply incremental migrations)
    for (final table in createTables) {
      await db.execute(table);
    }

    print('✅ Database schema upgrade complete.');
  }

  // Optional: for debugging or resetting the database
  Future<void> clearDatabase() async {
    final db = await database;
    final tables = [
      'users',
      'subscriptions',
      'user_activities',
      'projects',
      'selected_modules',
      'sections',
      'components',
      'items',
      'installed_modules',
      'modules',
      'user_modules',
      'reserved_user_modules',
    ];

    for (final table in tables) {
      await db.delete(table);
    }
    print('🧹 All database tables cleared.');
  }

  // Optional: drop and recreate all tables
  Future<void> resetDatabase() async {
    final db = await database;
    print('⚠️ Resetting database...');
    final tables = [
      'users',
      'subscriptions',
      'user_activities',
      'projects',
      'selected_modules',
      'sections',
      'components',
      'items',
      'installed_modules',
      'modules',
      'user_modules',
      'reserved_user_modules',
    ];

    // Drop tables in reverse order to satisfy FK dependencies
    for (final table in tables.reversed) {
      await db.execute('DROP TABLE IF EXISTS $table;');
    }

    // Recreate everything fresh
    await _onCreate(db, 1);
    print('✅ Database reset complete.');
  }
}
