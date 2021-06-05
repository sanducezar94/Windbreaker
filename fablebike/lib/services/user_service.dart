import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:path/path.dart';

import 'storage_service.dart';

//const SERVER_IP = '192.168.100.24:8080';
const SERVER_IP = 'lighthousestudio.ro';
const FILE_UPLOAD = '/auth/user_icon';
const FILE_GET = '/auth/user_icon';

class UserService {
  Future<bool> uploadProfileImage(File imageFile) async {
    try {
      var length = await imageFile.length();
      var storage = new StorageService();

      var uri = Uri.https(SERVER_IP, FILE_UPLOAD);
      var token = await storage.readValue('token');
      var request = new http.MultipartRequest('POST', uri);

      var multipartFile = new http.MultipartFile(
          'file', imageFile.readAsBytes().asStream(), length,
          filename: basename(imageFile.path));

      request.files.add(multipartFile);
      request.headers
          .addAll({HttpHeaders.authorizationHeader: 'Bearer ' + token});
      var response = await request.send();

      return true;
    } on SocketException {
      return false;
    } on Exception {
      return false;
    }
  }

  Future<String> getIcon({String imageName}) async {
    try {
      var client = http.Client();
      var storage = new StorageService();

      var token = await storage.readValue('token');

      var queryParameters = {'imagename': imageName};

      var response = await client
          .get(Uri.https(SERVER_IP, FILE_GET, queryParameters), headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token
      }).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 200) {
        var file = await storage.createUserIconWithFilename(
            imageName, response.bodyBytes);

        return file.path;
      }
      return 'none';
    } on SocketException {
      return 'none';
    } on Exception {
      return 'none';
    }
  }
}
