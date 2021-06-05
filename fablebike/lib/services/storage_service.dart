import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final storage = new FlutterSecureStorage();

  Future<bool> writeValue(String key, String value) async {
    try {
      await storage.write(key: key, value: value);
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<String> readValue(String key) async {
    try {
      var value = await storage.read(key: key);
      return value;
    } on Exception catch (e) {
      return '';
    }
  }

  Future<bool> deleteKey(String key) async {
    try {
      await storage.delete(key: key);
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    return file;
  }

  Future<File> createUserIconWithFilename(
      String filename, Uint8List fileStream) async {
    try {
      var docDir = await getApplicationDocumentsDirectory();
      String path = docDir.path + '/user_images';
      String finalPath = '$path/' + filename;
      File fifi = createFile(finalPath);
      fifi.writeAsBytesSync(fileStream);

      return fifi;
    } on Exception {
      return null;
    }
  }

  Future<File> createUserIconWithUsername(
      String filename, String userName, Uint8List fileStream) async {
    try {
      var docDir = await getApplicationDocumentsDirectory();
      String path = docDir.path + '/user_images';
      String extension = p.extension(filename);
      String fileName = userName + extension;
      String finalPath = '$path/' + fileName;
      File fifi = createFile(finalPath);
      fifi.writeAsBytesSync(fileStream);

      return fifi;
    } on Exception {
      return null;
    }
  }
}
