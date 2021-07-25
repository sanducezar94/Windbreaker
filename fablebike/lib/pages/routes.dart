import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/filters.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/card_builders.dart';
import 'package:fablebike/widgets/route_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fablebike/models/route.dart';
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
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        color: Colors.white,
        child: Scaffold(
            appBar: AppBar(
              shadowColor: Colors.white54,
              backgroundColor: Colors.white,
              centerTitle: true,
              iconTheme: IconThemeData(color: Theme.of(context).accentColor),
              title: Row(
                children: [
                  Expanded(
                      child: TextField(
                        onChanged: (context) {
                          setState(() {});
                        },
                        onTap: () {
                          if (sensibleSearch) {
                            searchController.text = '';
                            sensibleSearch = false;
                          }
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
                          contentPadding: EdgeInsets.all(20.0),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).accentColor,
                          ),
                          suffixIcon: this.searchController != null && this.searchController.text.length > 0
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      this.searchController.text = '';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    color: Theme.of(context).accentColor,
                                  ))
                              : null,
                          hintText: context.read<LanguageManager>().search,
                        ),
                      ),
                      flex: 9),
                  Expanded(
                      child: InkWell(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Icon(Icons.filter_list, color: Theme.of(context).accentColor)]),
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
                      context.read<LanguageManager>().routeAvailable,
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
                        if (filterQuery.indexOf('obiective:') > -1) {
                          filteredList = snapshot.data.where((element) => element.objectives.where((obj) => obj.id == widget.objective.id).length > 0).toList();
                        } else {
                          filteredList = snapshot.data
                              .where((c) =>
                                  ((c.difficulty >= routeFilter.difficulty.start && c.difficulty <= routeFilter.difficulty.end) &&
                                      (c.rating >= routeFilter.rating.start && c.rating <= routeFilter.rating.end) &&
                                      (c.distance >= routeFilter.distance.start && c.distance <= routeFilter.distance.end)) &&
                                  (c.name.toLowerCase().contains(filterQuery) || c.description.toLowerCase().contains(filterQuery)))
                              .toList();
                        }

                        for (var i = 0; i < filteredList.length; i++) {
                          children.add(CardBuilder.buildRouteCard(context, filteredList[i]));
                        }
                        return Column(children: children);
                      } else {
                        return Column(children: List.generate(3, (index) => CardBuilder.buildShimmerRouteCard(context)));
                      }
                    },
                    future: this.getBikeRoutes),
                SizedBox(height: 15),
              ],
            ))));
  }
}
