import 'dart:convert';

import 'package:fablebike/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/pages/map.dart';
import 'package:fablebike/services/route_service.dart';
import 'package:fablebike/widgets/drawer.dart';
import 'package:provider/provider.dart';

class RoutesScreen extends StatefulWidget {
  static const route = '/routes';
  RoutesScreen({Key key}) : super(key: key);

  @override
  _RoutesScreenState createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  Future<bool> getRoutes;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<BikeRoute>> getRoutes() async {
      var db = Provider.of<DatabaseService>(context);
      var database = await db.database;
      var routes = await database.query('route');

      return List.generate(routes.length, (i) {
        return BikeRoute.fromJson(routes[i]);
      });
    }

    return Scaffold(
        appBar: AppBar(title: Text('Map')),
        drawer: buildDrawer(context, '/routes'),
        body: FutureBuilder<List<BikeRoute>>(
            builder: (BuildContext context,
                AsyncSnapshot<List<BikeRoute>> snapshot) {
              List<Widget> children = [];
              if (snapshot.hasData) {
                for (var i = 0; i < snapshot.data.length; i++) {
                  children.add(_buildRoute(context, snapshot.data[i]));
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
            future: getRoutes()));
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
              try {
                var db = context.read<DatabaseService>();
                var database = await db.database;
                var routes = await database
                    .query('route', where: 'id = ?', whereArgs: [route.id]);

                var coords = await database.query('coord',
                    where: 'route_id = ?', whereArgs: [route.id]);
                var pois = await database.query('pointofinterest',
                    where: 'route_id = ?', whereArgs: [route.id]);

                var bikeRoute = new BikeRoute.fromJson(routes.first);
                bikeRoute.coordinates = List.generate(coords.length, (i) {
                  return Coords.fromJson(coords[i]);
                });
                bikeRoute.rtsCoordinates = List.generate(
                    coords.length, (i) => bikeRoute.coordinates[i].toLatLng());
                bikeRoute.pois = List.generate(pois.length, (i) {
                  return PointOfInterest.fromJson(pois[i]);
                });

                var serverRoute =
                    await RouteService().getRoute(route_id: bikeRoute.id);

                if (serverRoute != null) {
                  bikeRoute.rating = serverRoute.rating;
                  bikeRoute.ratingCount = serverRoute.ratingCount;
                }

                Navigator.pushNamed(context, MapScreen.route,
                    arguments: bikeRoute);
              } on Exception catch (e) {
                print(e);
              }
            })
      ]),
    ]),
  );
}
