import 'dart:async';
import 'dart:io';
import 'dart:convert';
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

  Future<bool> signIn({String email, String password}) async {
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
        var loggedUser = new AuthenticatedUser(body["user_id"], body["user"], email, response.body, body["icon"]);
        loggedUser.ratedComments = body["rated_comments"].cast<int>();
        loggedUser.ratedRoutes = body["rated_routes"].cast<int>();
        sc.add(new AuthenticatedUser(body["user_id"], body["user"], email, response.body, body["icon"]));
        return true;
      }

      return false;
    } on SocketException catch (e) {
      return false;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<bool> signUp({String user, String email, String password}) async {
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
        sc.add(new AuthenticatedUser(body["user_id"], user, email, response.body, "none"));
        return true;
      }

      return false;
    } on SocketException catch (e) {
      return false;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<bool> facebookSignUp({String user, String email}) async {
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
        sc.add(new AuthenticatedUser(body["user_id"], user, email, body["token"], "none"));
        return true;
      }

      return false;
    } on SocketException catch (e) {
      return false;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      sc.add(new AuthenticatedUser(-1, 'none', 'none', 'none', 'none'));
      var storage = new StorageService();
      storage.deleteKey('token');
      return true;
    } on Exception catch (e) {
      return false;
    }
  }
}
