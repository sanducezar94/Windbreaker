import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'storage_service.dart';

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
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
    }

    _database = await openDatabase(dbPath);
  }
}
