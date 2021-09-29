import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fablebike/models/service_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'storage_service.dart';

//const SERVER_IP = '192.168.1.251:8080';
const SERVER_IP = 'lighthousestudio.ro';
const FILE_UPLOAD = '/api/fablebike/auth/user_icon';
const FILE_GET = '/api/fablebike/auth/user_icon';
const OTP = '/api/fablebike/otp';
const TEST_IP = '192.168.1.251:8080';

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

  Future<ServiceResponse> getOtp({String email}) async {
    try {
      var client = http.Client();
      var queryParameters = {'email': email};

      var response = await client.get(Uri.http(TEST_IP, OTP, queryParameters)).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 200) {
        return ServiceResponse(true, response.body);
      }
      return ServiceResponse(false, response.body);
    } on SocketException {
      return ServiceResponse(false, CONNECTION_TIMEOUT_MESSAGE);
    } on Exception {
      return ServiceResponse(false, SERVER_ERROR_MESSAGE);
    }
  }

  Future<ServiceResponse> verifyOtp({String email, String otp}) async {
    try {
      var client = http.Client();
      var body = {'email': email, 'otp': otp};

      var response = await client.post(Uri.http(TEST_IP, OTP), body: body).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 200) {
        return ServiceResponse(true, response.body);
      }
      return ServiceResponse(false, response.body);
    } on SocketException {
      return ServiceResponse(false, CONNECTION_TIMEOUT_MESSAGE);
    } on Exception {
      return ServiceResponse(false, SERVER_ERROR_MESSAGE);
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

  Future<File> getOAuthIcon(String url) async {
    try {
      var client = http.Client();
      var storage = new StorageService();

      var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });
      if (response.statusCode == 200) {
        final appDirectory = await getApplicationDocumentsDirectory();

        if (File(join(appDirectory.path, 'profile_pic.jpg')).existsSync()) {
          var localFile = File(join(appDirectory.path, 'profile_pic.jpg'));
          await localFile.delete();
        }
        imageCache.clear();
        final file = File(join(appDirectory.path, 'profile_pic.jpg'));

        file.writeAsBytesSync(response.bodyBytes);

        return file;
      }

      return null;
    } on SocketException {
      return null;
    } on Exception {
      return null;
    }
  }
}
