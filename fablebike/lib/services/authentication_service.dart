import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:fablebike/models/service_response.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'storage_service.dart';

//const SERVER_IP = '192.168.1.251:8080';
const SERVER_IP = 'lighthousestudio.ro';
const AUTH = '/api/fablebike/auth';
const SIGNUP = '/api/fablebike/auth/sign_up';
const FACEBOOK_SIGNUP = '/api/fablebike/auth/oauth';
const FILE_UPLOAD = '/api/fablebike/auth/upload';
const PERSISTENT_LOGIN = '/api/fablebike/auth/persistent';
const CHANGE_PASSWORD = '/api/fablebike/auth/change_password';

class AuthenticationService {
  StreamController sc = new StreamController<AuthenticatedUser>();
  Stream<AuthenticatedUser> get authUser => sc.stream;

  Future<ServiceResponse> isPersistentUserLogged() async {
    try {
      var db = await DatabaseService().database;

      var persistentUserRow = await db.query('SystemValue', where: 'key = ?', whereArgs: ['puseremail']);

      if (persistentUserRow.length > 0) {
        var client = http.Client();
        var storage = new StorageService();

        var token = await storage.readValue('token');
        if (token == null) return ServiceResponse(false, null);

        var response = await client.get(Uri.https(SERVER_IP, PERSISTENT_LOGIN), headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token}).timeout(
            const Duration(seconds: 5), onTimeout: () {
          throw TimeoutException('Connection timed out!');
        });

        if (response.statusCode == 200) {
          var storage = new StorageService();
          var body = jsonDecode(response.body);
          var loggedUser = new AuthenticatedUser.fromJson(response.body);

          await storage.writeValue('token', body["token"]);
          await setUserData(loggedUser);
          sc.add(loggedUser);
          return ServiceResponse(true, null);
        }
      }

      return ServiceResponse(false, null);
    } on SocketException {
      return ServiceResponse(false, CONNECTION_TIMEOUT_MESSAGE);
    } on Exception {
      return ServiceResponse(false, SERVER_ERROR_MESSAGE);
    }
  }

  Future<void> setUserData(AuthenticatedUser loggedUser) async {
    var db = await DatabaseService().database;

    var dataUsageRow = await db.query('SystemValue', where: 'user_id = ? and key = ?', whereArgs: [loggedUser.id, 'datausage']);
    var languageRow = await db.query('SystemValue', where: 'user_id = ? and key = ?', whereArgs: [loggedUser.id, 'language']);

    var dataUsage = false;
    var language = true;

    if (dataUsageRow.length == 0 || languageRow.length == 0) {
      await db.insert('SystemValue', {'key': 'datausage', 'value': '0', 'user_id': loggedUser.id.toString()}, conflictAlgorithm: ConflictAlgorithm.replace);
      await db.insert('SystemValue', {'key': 'language', 'value': 'RO', 'user_id': loggedUser.id.toString()}, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      dataUsage = dataUsageRow.first['value'] == '0' ? false : true;
      language = languageRow.first['value'] == 'RO' ? true : false;
    }
    var dc = DateTime.now().subtract(Duration(hours: 12)).toIso8601String();
    await db.delete('usericon', where: 'created_on <= ?', whereArgs: [dc]);

    for (var i = 0; loggedUser.routes != null && i < loggedUser.routes.length; i++) {
      await db.update('route', {'rating': loggedUser.routes[i].rating, 'rating_count': loggedUser.routes[i].ratingCount},
          where: 'id = ?', whereArgs: [loggedUser.routes[i].objectId]);
    }

    for (var i = 0; loggedUser.objectives != null && i < loggedUser.objectives.length; i++) {
      await db.update('objective', {'rating': loggedUser.objectives[i].rating, 'rating_count': loggedUser.objectives[i].ratingCount},
          where: 'id = ?', whereArgs: [loggedUser.objectives[i].objectId]);
    }

    var persistentUserRow = await db.query('SystemValue', where: 'key = ?', whereArgs: ['puseremail']);

    if (persistentUserRow.length == 0) {
      db.insert('SystemValue', {'key': 'puseremail'});
    } else {}

    loggedUser.lowDataUsage = dataUsage;
    loggedUser.isRomanianLanguage = language;
  }

  Future<ServiceResponse> signIn({String email, String password}) async {
    try {
      var client = http.Client();
      String authToken = base64Encode(utf8.encode(email + ':' + password));
      var response = await client
          .get(Uri.https(SERVER_IP, AUTH), headers: {HttpHeaders.authorizationHeader: 'Basic ' + authToken}).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 200) {
        var storage = new StorageService();
        var body = jsonDecode(response.body);

        await storage.writeValue('token', body["token"]);
        var loggedUser = new AuthenticatedUser.fromJson(response.body);
        await setUserData(loggedUser);
        sc.add(loggedUser);
        return ServiceResponse(true, SUCCESS_MESSAGE);
      }

      return ServiceResponse(false, response.body);
    } on SocketException {
      return ServiceResponse(false, CONNECTION_TIMEOUT_MESSAGE);
    } on Exception {
      return ServiceResponse(false, SERVER_ERROR_MESSAGE);
    }
  }

  Future<ServiceResponse> signInFacebook({String email, String password, String facebookToken}) async {
    try {
      var client = http.Client();
      String authToken = base64Encode(utf8.encode(email + ':' + password));
      var parameters = {'oauth_token': facebookToken, 'provider': 'FACEBOOK'};
      var response = await client.get(Uri.https(SERVER_IP, FACEBOOK_SIGNUP, parameters),
          headers: {HttpHeaders.authorizationHeader: 'Basic ' + authToken}).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 200) {
        var storage = new StorageService();
        var body = jsonDecode(response.body);

        await storage.writeValue('token', body["token"]);
        var loggedUser = new AuthenticatedUser.fromJson(response.body);
        await setUserData(loggedUser);
        sc.add(loggedUser);
        return ServiceResponse(true, SUCCESS_MESSAGE);
      }

      return ServiceResponse(false, response.body);
    } on SocketException {
      return ServiceResponse(false, CONNECTION_TIMEOUT_MESSAGE);
    } on Exception {
      return ServiceResponse(false, SERVER_ERROR_MESSAGE);
    }
  }

  Future<ServiceResponse> signUp({String user, String email, String password}) async {
    try {
      var client = http.Client();
      var response = await client.post(
        Uri.https(SERVER_IP, SIGNUP),
        body: {'email': email, 'user': user, 'password': password},
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 201) {
        var storage = new StorageService();
        var body = jsonDecode(response.body);

        var newUser = new AuthenticatedUser.newUser(body['user_id'], user, email);
        await setUserData(newUser);

        storage.writeValue('token', body["token"]);

        var db = await DatabaseService().database;
        var profilePicRow = await db.query('usericon', where: 'name = ? and is_profile = ?', whereArgs: ['profile_pic_registration', 0], columns: ['blob']);

        if (profilePicRow.length > 0) {
          var profilePic = profilePicRow.first;
          await UserService().uploadProfileImage(profilePic['blob'], user + '.jpg');
        }

        sc.add(newUser);
        return ServiceResponse(true, SUCCESS_MESSAGE);
      }

      return ServiceResponse(false, response.body);
    } on SocketException {
      return ServiceResponse(false, CONNECTION_TIMEOUT_MESSAGE);
    } on Exception {
      return ServiceResponse(false, SERVER_ERROR_MESSAGE);
    }
  }

  Future<ServiceResponse> changePassword({String email, String password}) async {
    try {
      var client = http.Client();
      var response = await client.post(
        Uri.http(SERVER_IP, CHANGE_PASSWORD),
        body: {'email': email, 'password': password},
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 201) {
        var storage = new StorageService();
        var body = jsonDecode(response.body);

        var newUser = new AuthenticatedUser.newUser(body['user_id'], "", email);
        await setUserData(newUser);

        storage.writeValue('token', body["token"]);

        var db = await DatabaseService().database;

        sc.add(newUser);
        return ServiceResponse(true, SUCCESS_MESSAGE);
      }

      return ServiceResponse(false, response.body);
    } on SocketException {
      return ServiceResponse(false, CONNECTION_TIMEOUT_MESSAGE);
    } on Exception {
      return ServiceResponse(false, SERVER_ERROR_MESSAGE);
    }
  }

  Future<ServiceResponse> signInGuest() async {
    try {
      sc.add(new AuthenticatedUser.newUser(0, 'GUEST', 'GUEST'));
      return ServiceResponse(true, SUCCESS_MESSAGE);
    } on SocketException {
      return ServiceResponse(false, CONNECTION_TIMEOUT_MESSAGE);
    } on Exception {
      return ServiceResponse(false, SERVER_ERROR_MESSAGE);
    }
  }

  Future<ServiceResponse> facebookSignUp({String user, String email, String userToken}) async {
    try {
      var client = http.Client();
      var response = await client.post(
        Uri.https(SERVER_IP, FACEBOOK_SIGNUP),
        body: {'email': email, 'user': user, 'user_token': userToken},
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 200) {
        var storage = new StorageService();
        var body = jsonDecode(response.body);
        var newUser = new AuthenticatedUser.newUser(body["user_id"], user, email);
        await storage.writeValue('token', body['token']);

        var db = await DatabaseService().database;

        var profilePicRow = await db.query('usericon', where: 'name = ? and is_profile = ?', whereArgs: ['profile_pic_registration', 0], columns: ['blob']);

        if (profilePicRow.length > 0) {
          var profilePic = profilePicRow.first;
          await UserService().uploadProfileImage(profilePic['blob'], user + '.jpg');
        }

        await setUserData(newUser);
        sc.add(newUser);
        return ServiceResponse(true, SUCCESS_MESSAGE);
      }

      return ServiceResponse(false, response.body);
    } on SocketException {
      return ServiceResponse(false, CONNECTION_TIMEOUT_MESSAGE);
    } on Exception catch (e) {
      print(e.toString());
      return ServiceResponse(false, SERVER_ERROR_MESSAGE);
    }
  }

  Future<bool> signOut() async {
    try {
      sc.add(new AuthenticatedUser.emptyUser());
      var storage = new StorageService();
      storage.deleteKey('token');
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  bool hasReadPermission(AuthenticatedUser user) {
    if (user == null) return false;
    if (user.roleTokens.isEmpty) return false;
    return user.roleTokens.contains("r");
  }

  bool hasWritePermission(AuthenticatedUser user) {
    if (user == null) return false;
    if (user.roleTokens.isEmpty) return false;
    return user.roleTokens.contains("w");
  }

  bool hasDeletePermission(AuthenticatedUser user) {
    if (user == null) return false;
    if (user.roleTokens.isEmpty) return false;
    return user.roleTokens.contains("d");
  }
}
