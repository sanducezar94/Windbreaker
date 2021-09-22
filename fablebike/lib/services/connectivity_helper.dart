import 'dart:io';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class ConnectionStatusSingleton {
  static final ConnectionStatusSingleton _singleton = new ConnectionStatusSingleton._internal();

  ConnectionStatusSingleton._internal();

  static ConnectionStatusSingleton getInstance() => _singleton;

  bool hasConnection = false;
  final Connectivity _connectivity = Connectivity();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  StreamSubscription<ConnectivityResult> connectivitySubscription;
  StreamController _connectionChangeController = new StreamController.broadcast();

  Stream get connectionChange => _connectionChangeController.stream;

  void initialize() {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result;
      _connectionChangeController.add(_connectionStatus);
      hasConnection = _connectionStatus != ConnectivityResult.none;
    });
    initConnectivity();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
      _connectionStatus = result;
      _connectionChangeController.add(_connectionStatus);
      hasConnection = _connectionStatus != ConnectivityResult.none;
    } on PlatformException catch (e) {
      return;
    }
  }

  void dispose() {
    connectivitySubscription.cancel();
    _connectionChangeController.close();
  }
}
