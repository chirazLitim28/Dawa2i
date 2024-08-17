import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _database_name = "version_11.db";
  static const _database_version = 4;
  static var database;

  static Future getDatabase() async {
    if (database != null) {
      return database;
    }

    database = openDatabase(
      join(await getDatabasesPath(), _database_name),
      onCreate: (database, version) {
        database.execute('''
          CREATE TABLE medications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            dose INTEGER,
            num_pill INTEGER,
            date TEXT,
            notifyId INTEGER
          )
        ''');

        database.execute('''
          CREATE TABLE medication_times (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medication_id INTEGER,
            time TEXT,
            taken TEXT,
            FOREIGN KEY (medication_id) REFERENCES medications(id)
          )
        ''');
      },
      version: _database_version,
      onUpgrade: (db, oldVersion, newVersion) {
        // do nothing...
      },
    );
    return database;
  }
}
