import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
}
