import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'storage_service.dart';

//const SERVER_IP = '192.168.146.54:8080';
const SERVER_IP = 'lighthousestudio.ro';
const FILE_UPLOAD = '/auth/user_icon';
const FILE_GET = '/auth/user_icon';

class UserService {
  Future<bool> uploadProfileImage(Uint8List imageBytes, String filename) async {
    try {
      var length = await imageBytes.length;
      var storage = new StorageService();

      var uri = Uri.https(SERVER_IP, FILE_UPLOAD);
      var token = await storage.readValue('token');
      var request = new http.MultipartRequest('POST', uri);
      var stream = Stream.value(imageBytes);

      var multipartFile = new http.MultipartFile('file', stream, length, filename: filename);

      request.files.add(multipartFile);
      request.headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ' + token});
      var response = await request.send().timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      return true;
    } on SocketException {
      return false;
    } on Exception {
      return false;
    }
  }

  Future<Uint8List> getIcon({String imageName, int userId, String username}) async {
    try {
      var client = http.Client();
      var storage = new StorageService();

      var token = await storage.readValue('token');

      var queryParameters = {'imagename': imageName};

      var response = await client.get(Uri.https(SERVER_IP, FILE_GET, queryParameters), headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token}).timeout(
          const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 200) {
        await storage.storeUserIcon(userId, username, response.bodyBytes);
        return response.bodyBytes;
      }
      return null;
    } on SocketException {
      return null;
    } on Exception {
      return null;
    }
  }
}
