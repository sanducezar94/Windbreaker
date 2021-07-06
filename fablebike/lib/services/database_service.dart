import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database _database;

  Future<Database> get database async {
    if (_database == null) {
      await initDatabase();
      return _database;
    } else {
      return _database;
    }
  }

  initDatabase() async {
    var dbDir = await getDatabasesPath();
    var dbPath = join(dbDir, "fablebike.db");

    var exists = await databaseExists(dbPath);

    if (!exists) {
      await deleteDatabase(dbPath);

      ByteData data = await rootBundle.load("assets/data/fablebike.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
    }

    _database = await openDatabase(dbPath);
  }

  insert({String table, Map<String, dynamic> values}) async {
    try {
      var db = await this.database;
      await db.insert(table, values);
    } on Exception {}
  }

  update(String table, Map<String, dynamic> values, {String where, List<Object> args}) async {
    try {
      var db = await this.database;
      await db.update(table, values, where: where, whereArgs: args);
    } on Exception {}
  }

  delete(String table, {String where, List<Object> whereArgs}) async {
    try {
      var db = await this.database;
      await db.delete(table, where: where, whereArgs: whereArgs);
    } on Exception {}
  }

  Future<List<Map<String, Object>>> query(String table, {String where, List<Object> whereArgs, List<String> columns}) async {
    try {
      var db = await this.database;
      var values = await db.query(table, where: where, whereArgs: whereArgs, columns: columns);
      return values;
    } on Exception {
      return [];
    }
  }
}
