import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fablebike/models/route.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

const SERVER_IP = 'lighthousestudio.ro';
const API_ENDPOINT = '/api/fablebike/objective';

class ObjectiveService {
  Future<Objective> getObjective({int objective_id}) async {
    try {
      var connectivity = await (Connectivity().checkConnectivity());
      if (connectivity == ConnectivityResult.none) return null;

      var client = http.Client();
      var storage = new StorageService();

      var token = await storage.readValue('token');
      var queryParameters = {'objective_id': objective_id.toString()};

      var response = await client.get(Uri.https(SERVER_IP, API_ENDPOINT, queryParameters),
          headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token}).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 200) {
        var bodyJSON = jsonDecode(response.body);
        return Objective.fromJson(bodyJSON);
      }
      return null;
    } on SocketException {
      return null;
    } on Exception {
      return null;
    }
  }

  Future<double> rateObjective({int objective_id, int rating}) async {
    try {
      var client = http.Client();
      var storage = new StorageService();

      var token = await storage.readValue('token');
      var response = await client.post(Uri.https(SERVER_IP, API_ENDPOINT),
          body: {'rating': rating.toString(), 'objective_id': objective_id.toString()},
          headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token}).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 200) {
        var bodyJSON = jsonDecode(response.body);
        return bodyJSON["rating"];
      } else {
        return 0.0;
      }
    } on SocketException {
      return 0.0;
    } on Exception {
      return 0.0;
    }
  }
}
