import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/pages/map.dart';
import 'package:fablebike/services/route_service.dart';
import 'package:fablebike/widgets/drawer.dart';

import 'dart:math' show cos, sqrt, asin;

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

class RoutesScreen extends StatefulWidget {
  static const route = '/routes';
  RoutesScreen({Key key}) : super(key: key);

  @override
  _RoutesScreenState createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  List<BikeRoute> routes = [];
  Future<bool> getRoutes;

  Future<bool> loadJsonData() async {
    if (this.routes.length > 0) return false;
    var jsonText = await rootBundle.loadString('assets/data/trasee.json');
    var jsonRoutes = jsonDecode(jsonText);
    for (var i = 0; i < jsonRoutes.length; i++) {
      this.routes.add(BikeRoute.fromJson(jsonRoutes[i]));
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    getRoutes = loadJsonData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Map')),
        drawer: buildDrawer(context, '/routes'),
        body: FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              List<Widget> children = [];
              if (snapshot.hasData) {
                for (var i = 0; i < this.routes.length; i++) {
                  children.add(_buildRoute(context, this.routes[i]));
                }
                return Container(
                  color: Colors.white70,
                  child: ListView(
                      children: children, scrollDirection: Axis.vertical),
                );
              } else {
                return Text('Loading...');
              }
            },
            future: this.getRoutes));
  }
}

Widget _buildRoute(BuildContext context, BikeRoute route) {
  return Card(
    clipBehavior: Clip.antiAlias,
    child: Column(children: [
      ListTile(
        leading: Icon(Icons.map),
        title: Text(route.name),
        subtitle: Text(route.description),
      ),
      ButtonBar(alignment: MainAxisAlignment.start, children: [
        ElevatedButton(
            child: Text('Mai multe...'),
            onPressed: () async {
              var jsonText = await rootBundle.loadString(route.file);

              var bikeRoute = BikeRoute.fromJson(jsonDecode(jsonText));
              var serverRoute =
                  await RouteService().getRoute(route_id: bikeRoute.id);

              if (serverRoute != null) {
                bikeRoute.rating = serverRoute.rating;
                bikeRoute.ratingCount = serverRoute.ratingCount;
              }

              Navigator.pushNamed(context, MapScreen.route,
                  arguments: bikeRoute);
            })
      ]),
    ]),
  );
}
