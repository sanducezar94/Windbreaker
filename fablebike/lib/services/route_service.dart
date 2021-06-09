import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fablebike/models/route.dart';
import 'package:http/http.dart' as http;
import 'database_service.dart';
import 'storage_service.dart';

//const SERVER_IP = '192.168.100.24:8080';
const SERVER_IP = 'lighthousestudio.ro';
const API_ENDPOINT = '/route';

class RouteService {
  Future<BikeRoute> getRoute({int route_id}) async {
    try {
      var connectivity = await (Connectivity().checkConnectivity());
      if (connectivity == ConnectivityResult.none) return null;

      var client = http.Client();
      var storage = new StorageService();

      var token = await storage.readValue('token');
      var queryParameters = {'route_id': route_id.toString()};

      var response = await client.get(Uri.https(SERVER_IP, API_ENDPOINT, queryParameters),
          headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token}).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      var bodyJSON = jsonDecode(response.body);
      return BikeRoute.fromJson(bodyJSON);
    } on SocketException {
      return null;
    } on Exception {
      return null;
    }
  }

  Future<double> rateRoute({int route_id, int rating}) async {
    try {
      var client = http.Client();
      var storage = new StorageService();

      var token = await storage.readValue('token');
      var response = await client.post(Uri.https(SERVER_IP, API_ENDPOINT),
          body: {'rating': rating.toString(), 'route_id': route_id.toString()},
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
