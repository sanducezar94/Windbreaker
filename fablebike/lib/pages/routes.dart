import 'dart:math';
import 'dart:ui';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/bloc/route_bloc.dart';
import 'package:fablebike/models/comments.dart';
import 'package:fablebike/models/filters.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/route_map.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/route_service.dart';
import 'package:fablebike/widgets/card_builder.dart';
import 'package:fablebike/widgets/routes_carousel.dart';
import 'package:fablebike/widgets/shimmer_card_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fablebike/models/route.dart';
import 'package:provider/provider.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

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
  RouteBloc _bloc = new RouteBloc();
  RouteFilter initialFilter = new RouteFilter();
  RouteFilter routeFilter = new RouteFilter();
  AuthenticatedUser _user;

  @override
  void initState() {
    super.initState();

    _user = context.read<AuthenticatedUser>();
    _bloc.objectiveEventSync.add(RouteBlocEvent(eventType: RouteEventType.RouteInitializeEvent, args: {'user_id': _user.id}));
    getBikeRoutes = _getRoutes();
  }

  Future<List<BikeRoute>> _getRoutes({bool mostPopular: false}) async {
    var database = await DatabaseService().database;
    var routes = await database.query('route');

    List<BikeRoute> bikeRoutes = List.generate(routes.length, (i) {
      return BikeRoute.fromJson(routes[i]);
    });
    double meanRating = 0;
    double routeCount = 0;
    for (var i = 0; i < bikeRoutes.length; i++) {
      var objToRoutes = await database.query('objectivetoroute', where: 'route_id = ?', whereArgs: [bikeRoutes[i].id]);

      if (bikeRoutes[i].rating > 0) {
        meanRating += bikeRoutes[i].rating;
        routeCount += 1;
      }

      List<Objective> objectives = [];
      for (var i = 0; i < objToRoutes.length; i++) {
        var objRow = await database.query('objective', where: 'id = ?', whereArgs: [objToRoutes[i]['objective_id']]);
        if (objRow.length > 1 || objRow.length == 0) continue;
        objectives.add(Objective.fromJson(objRow.first));
      }
      bikeRoutes[i].objectives = objectives;
    }

    meanRating = meanRating / routeCount;

    if (mostPopular) {
      var popularRoutes = bikeRoutes;
      popularRoutes.sort((a, b) {
        var ratingLimit = 10;
        if (a == null || b == null) return null;
        if (a.ratingCount < ratingLimit || b.rating < ratingLimit) {
          if (a.rating > b.rating) return -1;
          if (a.rating < b.rating) return 1;
          if (a.rating == b.rating) return 0;
          return null;
        }
        var aWeight = (a.rating * a.ratingCount + meanRating * ratingLimit) / (a.rating + ratingLimit);
        var bWeight = (b.rating * b.ratingCount + meanRating * ratingLimit) / (b.rating + ratingLimit);

        if (a.rating == 0) return 1;
        if (b.rating == 0) return -1;

        if (aWeight > bWeight) return -1;
        if (bWeight > aWeight) return 1;
        if (aWeight == bWeight) return 0;
        return null;
      });

      return popularRoutes;
    }
    return bikeRoutes;
  }

  _goToRoute(BikeRoute route) async {
    try {
      Loader.show(context, progressIndicator: CircularProgressIndicator(color: Theme.of(context).primaryColor));
      var database = await DatabaseService().database;
      var routes = await database.query('route', where: 'id = ?', whereArgs: [route.id]);

      var coords = await database.query('coord', where: 'route_id = ?', whereArgs: [route.id]);

      var objToRoutes = await database.query('objectivetoroute', where: 'route_id = ?', whereArgs: [route.id]);

      List<Objective> objectives = [];
      for (var i = 0; i < objToRoutes.length; i++) {
        var objRow = await database.query('objective', where: 'id = ?', whereArgs: [objToRoutes[i]['objective_id']]);
        if (objRow.length > 1 || objRow.length == 0) continue;
        objectives.add(Objective.fromJson(objRow.first));
      }

      var bikeRoute = new BikeRoute.fromJson(routes.first);
      bikeRoute.coordinates = List.generate(coords.length, (i) {
        return Coordinates.fromJson(coords[i]);
      });
      bikeRoute.rtsCoordinates = List.generate(coords.length, (i) => bikeRoute.coordinates[i].toLatLng());
      bikeRoute.elevationPoints = List.generate(coords.length, (i) => bikeRoute.coordinates[i].toElevationPoint());
      bikeRoute.objectives = objectives;

      var serverRoute = await RouteService().getRoute(route_id: bikeRoute.id);

      if (serverRoute != null) {
        await database.update('route', {'rating': serverRoute.rating, 'rating_count': serverRoute.ratingCount}, where: 'id = ?', whereArgs: [bikeRoute.id]);
        bikeRoute.rating = serverRoute.rating;
        bikeRoute.ratingCount = serverRoute.ratingCount;
        bikeRoute.commentCount = serverRoute.commentCount;
        bikeRoute.userRating = serverRoute.userRating;
      }

      var db = await DatabaseService().database;

      var pinnedRouteRow = await db.query('routepinnedcomment', where: 'route_id = ?', whereArgs: [bikeRoute.id]);
      if (pinnedRouteRow.length > 0) {
        bikeRoute.pinnedComment = RoutePinnedComment.fromMap(pinnedRouteRow.first);
      }
      Navigator.of(context).pushNamed(RouteMapScreen.route, arguments: bikeRoute).then((newRating) async {
        var finalRating = newRating as double;

        if (newRating == null) {
          var db = await DatabaseService().database;
          var routeRow = await db.query('route', where: 'id = ?', whereArgs: [bikeRoute.id]);
          if (routeRow.length > 0) finalRating = routeRow.first['rating'];
        }
        if (finalRating != null && finalRating > 0.0) {
          _bloc.objectiveEventSync.add(RouteBlocEvent(eventType: RouteEventType.RouteRateEvent, args: {'id': bikeRoute.id, 'rating': finalRating}));
          _bloc.objectiveEventSync.add(RouteBlocEvent(eventType: RouteEventType.RouteSearchEvent, args: {'search_query': searchController.text}));
        }
      });
      Loader.hide();
    } on Exception catch (e) {
      Loader.hide();
    }
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
                                        onChanged: (context) {
                                          _bloc.objectiveEventSync
                                              .add(RouteBlocEvent(eventType: RouteEventType.RouteSearchEvent, args: {'search_query': searchController.text}));
                                          setState(() {});
                                        },
                                        controller: searchController,
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
                          if (searchController.text == '')
                            Row(children: [
                              Text(
                                "Trasee populare",
                                style: Theme.of(context).textTheme.headline2,
                                textAlign: TextAlign.start,
                              )
                            ]),
                          SizedBox(height: smallDivider),
                          if (searchController.text == '')
                            FutureBuilder<List<BikeRoute>>(
                                builder: (context, AsyncSnapshot<List<BikeRoute>> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                                    return Container(
                                      child: RouteCarousel(
                                        context: context,
                                        routes: snapshot.data,
                                        width: width * 0.4,
                                      ),
                                      height: height * 0.325,
                                      width: 999,
                                    );
                                  } else {
                                    return Container(
                                      child: RouteCarousel(
                                        context: context,
                                        routes: snapshot.data,
                                        width: width * 0.4,
                                        isShimer: true,
                                      ),
                                      height: height * 0.325,
                                      width: 999,
                                    );
                                  }
                                },
                                future: _getRoutes(mostPopular: true)),
                          SizedBox(height: bigDivider),
                          Row(children: [
                            Text(
                              "Toate traseele",
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.start,
                            )
                          ]),
                          SizedBox(height: smallDivider),
                          StreamBuilder<List<BikeRoute>>(
                            builder: (BuildContext context, AsyncSnapshot<List<BikeRoute>> snapshot) {
                              if (snapshot.hasData && snapshot.data.length > 0) {
                                return Column(
                                  children: [
                                    for (var i = 0; i < snapshot.data.length; i++)
                                      Padding(
                                        child: InkWell(
                                          child: Container(
                                            decoration: BoxDecoration(boxShadow: [
                                              BoxShadow(
                                                  color: Theme.of(context).shadowColor.withOpacity(0.125), spreadRadius: 6, blurRadius: 9, offset: Offset(0, 0))
                                            ]),
                                            child: CardBuilder.buildBigRouteCard(context, snapshot.data[i]),
                                          ),
                                          onTap: () async {
                                            _goToRoute(snapshot.data[i]);
                                          },
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                                      ),
                                  ],
                                );
                              } else {
                                return Column(children: [for (var i = 0; i < 5; i++) ShimmerCardBuilder.buildlargeObjectiveCard(context)]);
                              }
                            },
                            initialData: [],
                            stream: _bloc.output,
                          ),
                          SizedBox(height: smallDivider),
                        ]))))));
  }
}
