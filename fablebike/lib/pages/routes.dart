import 'dart:math';
import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/filters.dart';
import 'package:fablebike/pages/route_map.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/card_builders.dart';
import 'package:fablebike/widgets/route_filter.dart';
import 'package:fablebike/widgets/routes_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fablebike/models/route.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';

class RoutesScreen extends StatefulWidget {
  static const route = '/routes';

  final Objective objective;
  RoutesScreen({Key key, this.objective = null}) : super(key: key);

  @override
  _RoutesScreenState createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  Future<bool> getRoutes;
  TextEditingController searchController = TextEditingController();
  bool sensibleSearch = false;
  Future<List<BikeRoute>> getBikeRoutes;
  RouteFilter initialFilter = new RouteFilter();
  RouteFilter routeFilter = new RouteFilter();

  @override
  void initState() {
    super.initState();
    getBikeRoutes = _getRoutes();
    if (widget.objective != null) {
      searchController.text = 'obiective:' + widget.objective.name;
      sensibleSearch = true;
    }
  }

  Future<List<BikeRoute>> _getRoutes() async {
    var database = await DatabaseService().database;
    var routes = await database.query('route');

    List<BikeRoute> bikeRoutes = List.generate(routes.length, (i) {
      return BikeRoute.fromJson(routes[i]);
    });

    for (var i = 0; i < bikeRoutes.length; i++) {
      var objToRoutes = await database.query('objectivetoroute', where: 'route_id = ?', whereArgs: [bikeRoutes[i].id]);

      List<Objective> objectives = [];
      for (var i = 0; i < objToRoutes.length; i++) {
        var objRow = await database.query('objective', where: 'id = ?', whereArgs: [objToRoutes[i]['objective_id']]);
        if (objRow.length > 1 || objRow.length == 0) continue;
        objectives.add(Objective.fromJson(objRow.first));
      }
      bikeRoutes[i].objectives = objectives;
    }

    return bikeRoutes;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    double smallDivider = 10.0;
    double bigDivider = 20.0;
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SafeArea(
            child: Scaffold(
                body: SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        child: Column(children: [
                          CardBuilder.buildProfileBar(context, 'Trasee', '21+ trasee'),
                          SizedBox(height: bigDivider),
                          Container(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Material(
                                      child: TextField(
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.search),
                                            fillColor: Colors.white,
                                            hintStyle: TextStyle(fontSize: 16.0, color: Theme.of(context).accentColor.withOpacity(0.5)),
                                            filled: true,
                                            contentPadding: EdgeInsets.all(0),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                            hintText: 'Cauta traseu...'),
                                      ),
                                      shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                      borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                      elevation: 10.0,
                                    ),
                                    flex: 1)
                              ],
                            ),
                            height: 48,
                            width: 999,
                          ),
                          SizedBox(height: bigDivider),
                          Row(children: [
                            Text(
                              "Trasee populare",
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.start,
                            )
                          ]),
                          Container(
                            child: RouteCarousel(
                              context: context,
                              routes: [],
                              width: width * 0.45,
                            ),
                            height: height * 0.45,
                            width: 999,
                          ),
                          Row(children: [
                            Text(
                              "Toate traseele",
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.start,
                            )
                          ]),
                          SizedBox(height: smallDivider),
                          FutureBuilder<List<BikeRoute>>(
                              builder: (context, AsyncSnapshot<List<BikeRoute>> snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  if (snapshot.hasData && snapshot.data != null) {
                                    return Column(
                                      children: [
                                        for (var i = 0; i < 5; i++)
                                          Padding(
                                            child: InkWell(
                                              child: Container(
                                                decoration: BoxDecoration(boxShadow: [
                                                  BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))
                                                ]),
                                                child: CardBuilder.buildBigRouteCard(context),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pushNamed(RouteMapScreen.route, arguments: snapshot.data[i]);
                                              },
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                                          ),
                                      ],
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                              future: _getRoutes()),
                        ]))))));
  }
}
