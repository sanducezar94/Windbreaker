import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/models/filters.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/card_builders.dart';
import 'package:fablebike/widgets/route_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/pages/map.dart';
import 'package:fablebike/services/route_service.dart';
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

    /*for (var i = 0; i < bikeRoutes.length; i++) {
      var objectives = await database.query('objective', where: 'route_id = ?', whereArgs: [bikeRoutes[i].id], columns: ['name', 'latitude', 'longitude']);
      bikeRoutes[i].objectives = List.generate(objectives.length, (i) {
        return Objective.fromJson(objectives[i]);
      });
    }*/

    return bikeRoutes;
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        color: Colors.white,
        child: Scaffold(
            appBar: AppBar(
              shadowColor: Colors.white54,
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Expanded(
                      child: TextField(
                        onChanged: (context) {
                          setState(() {});
                        },
                        controller: searchController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).primaryColor,
                          ),
                          suffixIcon: this.searchController != null && this.searchController.text.length > 0
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      this.searchController.text = '';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Theme.of(context).primaryColor,
                                  ))
                              : null,
                          hintText: 'Cauta',
                        ),
                      ),
                      flex: 7),
                  Expanded(
                      child: InkWell(
                        child:
                            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Icon(Icons.filter_list, color: Theme.of(context).primaryColor)]),
                        onTap: () async {
                          var filter = await showDialog(context: context, builder: (_) => RouteFilterDialog(filter: routeFilter));
                          if (filter == null) return;
                          setState(() {
                            routeFilter = filter;
                          });
                        },
                      ),
                      flex: 1),
                ],
              ),
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                  child: Row(children: [
                    Icon(Icons.map_outlined),
                    SizedBox(width: 5),
                    Text(
                      'Lista rutelor disponibile',
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.start,
                    )
                  ]),
                ),
                SizedBox(height: 15),
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
                                    (c.distance >= routeFilter.distance.start && c.distance <= routeFilter.distance.end)) &&
                                (c.name.toLowerCase().contains(filterQuery) || c.description.toLowerCase().contains(filterQuery)))
                            .toList();

                        for (var i = 0; i < filteredList.length; i++) {
                          children.add(CardBuilder.buildRouteCard(context, filteredList[i]));
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
                var objectives = await database.query('objective', where: 'route_id = ?', whereArgs: [route.id]);

                var bikeRoute = new BikeRoute.fromJson(routes.first);
                bikeRoute.coordinates = List.generate(coords.length, (i) {
                  return Coordinates.fromJson(coords[i]);
                });
                bikeRoute.rtsCoordinates = List.generate(coords.length, (i) => bikeRoute.coordinates[i].toLatLng());
                bikeRoute.elevationPoints = List.generate(coords.length, (i) => bikeRoute.coordinates[i].toElevationPoint());
                bikeRoute.objectives = List.generate(objectives.length, (i) {
                  return Objective.fromJson(objectives[i]);
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
