import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:path/path.dart';

import 'storage_service.dart';

const SERVER_IP = '192.168.100.24:8080';
//const SERVER_IP = 'lighthousestudio.ro';
const AUTH = '/auth';
const SIGNUP = '/auth/sign_up';
const FILE_UPLOAD = '/auth/upload';

class UserService {
  Future<bool> uploadProfileImage(File imageFile, String filename) async {
    var length = await imageFile.length();
    var storage = new StorageService();

    //var uri = Uri.https(SERVER_IP, FILE_UPLOAD);
    var token = await storage.readValue('token');
    var uri = Uri.parse('http://192.168.100.24:8080/auth');
    var request = new http.MultipartRequest('POST', uri);

    var multipartFile = new http.MultipartFile(
        'file', imageFile.readAsBytes().asStream(), length,
        filename: filename);

    request.files.add(multipartFile);
    request.headers
        .addAll({HttpHeaders.authorizationHeader: 'Bearer ' + token});
    var response = await request.send();

    return true;
  }
}
