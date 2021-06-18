import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:fablebike/models/service_response.dart';
import 'package:fablebike/models/user.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

//const SERVER_IP = '192.168.100.24:8080';
const SERVER_IP = 'lighthousestudio.ro';
const AUTH = '/auth';
const SIGNUP = '/auth/sign_up';
const FACEBOOK_SIGNUP = '/auth/facebook';
const FILE_UPLOAD = '/auth/upload';

class AuthenticationService {
  StreamController sc = new StreamController<AuthenticatedUser>();
  Stream<AuthenticatedUser> get authUser => sc.stream;

  Future<ServiceResponse> signIn({String email, String password}) async {
    try {
      var client = http.Client();
      String authToken = base64Encode(utf8.encode(email + ':' + password));
      var response = await client
          .get(Uri.https(SERVER_IP, AUTH), headers: {HttpHeaders.authorizationHeader: 'Basic ' + authToken}).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 202) {
        var storage = new StorageService();
        var body = jsonDecode(response.body);

        await storage.writeValue('token', body["token"]);
        var loggedUser = new AuthenticatedUser(body["user_id"], body["user"], email, response.body, body["icon"], body["roles"]);
        loggedUser.ratedComments = body["rated_comments"].cast<int>();
        loggedUser.ratedRoutes = body["rated_routes"].cast<int>();
        sc.add(new AuthenticatedUser(body["user_id"], body["user"], email, response.body, body["icon"], body["roles"]));
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

        storage.writeValue('token', body["token"]);
        sc.add(new AuthenticatedUser(body["user_id"], user, email, response.body, "none", "rw"));
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
      var client = http.Client();
      String authToken = base64Encode(utf8.encode('GUEST:GUEST'));
      var response = await client
          .get(Uri.https(SERVER_IP, AUTH), headers: {HttpHeaders.authorizationHeader: 'Basic ' + authToken}).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 202) {
        var storage = new StorageService();
        var body = jsonDecode(response.body);

        await storage.writeValue('token', body["token"]);
        sc.add(new AuthenticatedUser(0, 'GUEST', 'GUEST', body['token'], '', 'r'));
        return ServiceResponse(true, SUCCESS_MESSAGE);
      }

      return ServiceResponse(false, response.body);
    } on SocketException {
      return ServiceResponse(false, CONNECTION_TIMEOUT_MESSAGE);
    } on Exception {
      return ServiceResponse(false, SERVER_ERROR_MESSAGE);
    }
  }

  Future<ServiceResponse> facebookSignUp({String user, String email}) async {
    try {
      var client = http.Client();
      var response = await client.post(
        Uri.https(SERVER_IP, FACEBOOK_SIGNUP),
        body: {'email': email, 'user': user},
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 200) {
        var storage = new StorageService();
        var body = jsonDecode(response.body);
        storage.writeValue('token', response.body);
        sc.add(new AuthenticatedUser(body["user_id"], user, email, body["token"], "none", "rw"));
        return ServiceResponse(true, SUCCESS_MESSAGE);
      }

      return ServiceResponse(false, response.body);
    } on SocketException {
      return ServiceResponse(false, CONNECTION_TIMEOUT_MESSAGE);
    } on Exception {
      return ServiceResponse(false, SERVER_ERROR_MESSAGE);
    }
  }

  Future<bool> signOut() async {
    try {
      sc.add(new AuthenticatedUser(-1, 'none', 'none', 'none', 'none', ""));
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