import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  TextEditingController searchController = TextEditingController();
  Future<List<BikeRoute>> getBikeRoutes;
  RouteFilter initialFilter = new RouteFilter();
  RouteFilter routeFilter = new RouteFilter();

  @override
  void initState() {
    super.initState();
    getBikeRoutes = _getRoutes();
  }

  Future<List<BikeRoute>> _getRoutes() async {
    var database = await DatabaseService().database;
    var routes = await database.query('route');

    List<BikeRoute> bikeRoutes = List.generate(routes.length, (i) {
      return BikeRoute.fromJson(routes[i]);
    });

    for (var i = 0; i < bikeRoutes.length; i++) {
      var pois = await database.query('pointofinterest', where: 'route_id = ?', whereArgs: [bikeRoutes[i].id], columns: ['name', 'latitude', 'longitude']);
      bikeRoutes[i].pois = List.generate(pois.length, (i) {
        return PointOfInterest.fromJson(pois[i]);
      });
    }

    return bikeRoutes;
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
            appBar: AppBar(title: Text('Map')),
            drawer: buildDrawer(context, '/routes'),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.filter_list),
              backgroundColor: Colors.blue,
              onPressed: () async {
                var filter = await showDialog(context: context, builder: (_) => FilterDialog(filter: routeFilter));
                if (filter == null) return;
                setState(() {
                  routeFilter = filter;
                });
              },
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (context) {
                      setState(() {});
                    },
                    controller: searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(24.0))),
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: this.searchController != null && this.searchController.text.length > 0
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  this.searchController.text = '';
                                });
                              },
                              icon: Icon(Icons.cancel))
                          : null,
                      hintText: 'Cauta',
                    ),
                  ),
                ),
                FutureBuilder<List<BikeRoute>>(
                    builder: (BuildContext context, AsyncSnapshot<List<BikeRoute>> snapshot) {
                      List<Widget> children = [];
                      if (snapshot.hasData) {
                        var filteredList = snapshot.data;
                        var filterQuery = this.searchController.text?.toLowerCase();
                        filteredList = snapshot.data
                            .where((c) =>
                                ((c.difficulty >= routeFilter.difficulty.start && c.difficulty <= routeFilter.difficulty.end) &&
                                    (c.rating >= routeFilter.rating.start && c.rating <= routeFilter.rating.end) &&
                                    (c.distance >= routeFilter.distance.start && c.distance <= routeFilter.distance.end) &&
                                    (c.pois.length >= routeFilter.poiCount.start && c.pois.length <= routeFilter.poiCount.end)) &&
                                (c.name.toLowerCase().contains(filterQuery) ||
                                    c.description.toLowerCase().contains(filterQuery) ||
                                    c.pois.where((p) => p.name.toLowerCase().contains(filterQuery)).isNotEmpty))
                            .toList();

                        for (var i = 0; i < filteredList.length; i++) {
                          children.add(_buildRoute(context, filteredList[i]));
                        }
                        return Column(children: children);
                      } else {
                        return Text('Loading...');
                      }
                    },
                    future: this.getBikeRoutes),
              ],
            ))));
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
                var routes = await database.query('route', where: 'id = ?', whereArgs: [route.id]);

                var coords = await database.query('coord', where: 'route_id = ?', whereArgs: [route.id]);
                var pois = await database.query('pointofinterest', where: 'route_id = ?', whereArgs: [route.id]);

                var bikeRoute = new BikeRoute.fromJson(routes.first);
                bikeRoute.coordinates = List.generate(coords.length, (i) {
                  return Coords.fromJson(coords[i]);
                });
                bikeRoute.rtsCoordinates = List.generate(coords.length, (i) => bikeRoute.coordinates[i].toLatLng());
                bikeRoute.elevationPoints = List.generate(coords.length, (i) => bikeRoute.coordinates[i].toElevationPoint());
                bikeRoute.pois = List.generate(pois.length, (i) {
                  return PointOfInterest.fromJson(pois[i]);
                });

                var serverRoute = await RouteService().getRoute(route_id: bikeRoute.id);

                if (serverRoute != null) {
                  database.update('route', {'rating': serverRoute.rating, 'rating_count': serverRoute.ratingCount}, where: 'id = ?', whereArgs: [bikeRoute.id]);
                  bikeRoute.rating = serverRoute.rating;
                  bikeRoute.ratingCount = serverRoute.ratingCount;
                }

                Navigator.pushNamed(context, MapScreen.route, arguments: bikeRoute);
              } on Exception catch (e) {
                print(e);
              }
            })
      ]),
    ]),
  );
}
