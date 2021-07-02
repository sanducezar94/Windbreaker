import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/widgets/route_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/pages/sections/map_section.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatelessWidget {
  static const route = '/map';

  final BikeRoute bikeRoute;

  const MapScreen({
    Key key,
    @required this.bikeRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MapWidget(bikeRoute: bikeRoute);
  }
}

class MapWidget extends StatefulWidget {
  const MapWidget({
    Key key,
    @required this.bikeRoute,
  }) : super(key: key);

  final BikeRoute bikeRoute;

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final ScrollController listViewController = ScrollController();
  bool isLoading = false;
  String currentRoute = "poi";

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    this.setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      this.setState(() {
        _connectionStatus = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    var user = Provider.of<AuthenticatedUser>(context);

    if (widget.bikeRoute == null) {
      Navigator.of(context).pop();
    }
    if (widget.bikeRoute != null)
      return ColorfulSafeArea(
          overflowRules: OverflowRules.all(true),
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Scaffold(
              resizeToAvoidBottomInset: true,
              //bottomNavigationBar: routeBottomBar(context, currentRoute),
              appBar: AppBar(
                title: Text(
                  widget.bikeRoute.name,
                  style: Theme.of(context).textTheme.headline3,
                ),
                shadowColor: Colors.white54,
                backgroundColor: Colors.white,
              ),
              body: SingleChildScrollView(
                child: Padding(padding: EdgeInsets.all(20.0), child: Column(children: [MapSection(bikeRoute: widget.bikeRoute)])),
              )));
  }
}
