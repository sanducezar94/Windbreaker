import 'package:fablebike/bloc/event_constants.dart';
import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/bookmarks.dart';
import 'package:fablebike/pages/map.dart';
import 'package:fablebike/pages/objective.dart';
import 'package:fablebike/pages/routes.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/route_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CardBuilder {
  static Widget buildAnnouncementBanner(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 3))]),
          height: 0.2 * height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 10.0),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Anunt Important',
                              style: Theme.of(context).textTheme.headline1,
                            ))
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Anunt Important',
                              style: Theme.of(context).textTheme.headline2,
                            ))
                      ],
                    )
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(flex: 2, child: SizedBox(width: 1)),
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text(context.read<LanguageManager>().details),
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: Size(64, 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
                                )))
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  static Widget buildAnnouncementBannerShimmer(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Shimmer.fromColors(
        highlightColor: Colors.white,
        baseColor: Colors.black.withOpacity(0.01),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                color: Colors.white,
              ),
              height: 0.2 * height,
            )));
  }

  static Widget buildSmallObjectiveShimmerCard(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: InkWell(
            onTap: () {},
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
                width: 0.35 * width,
                height: 0.275 * height,
                child: Stack(
                  children: [
                    Shimmer.fromColors(
                      highlightColor: Colors.white,
                      baseColor: Colors.black54,
                      child: Column(
                        children: [
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                child: Shimmer.fromColors(
                                    highlightColor: Colors.white,
                                    baseColor: Colors.black26,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                      ),
                                    )),
                              ),
                              flex: 2),
                          Container(
                              height: 1 / 10 * height,
                              child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: Column(children: [
                                    Expanded(
                                      child: Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.black12,
                                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                        ),
                                      ),
                                    ),
                                    Spacer(
                                      flex: 1,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.black12,
                                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                        ),
                                      ),
                                    ),
                                    Spacer(
                                      flex: 2,
                                    ),
                                  ])))
                        ],
                      ),
                    ),
                  ],
                ))));
  }

  static Widget buildSmallObjectiveCard(BuildContext context, Objective objective) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: InkWell(
            onTap: () {
              var objectiveInfo = new ObjectiveInfo(objective: objective, fromRoute: ModalRoute.of(context).settings.name);
              Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo);
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
                width: 0.35 * width,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                child: ClipRRect(
                                  child: Image.asset(
                                    'assets/images/bisericalemn_000.jpg',
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                )),
                            flex: 12),
                        Expanded(
                          child: Container(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Text(objective.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline4))),
                          flex: 6,
                        )
                      ],
                    ),
                    Align(
                        alignment: FractionalOffset(0.5, 0.65),
                        child: Image.asset(
                          'assets/icons/church_marker.png',
                          height: 40,
                          width: 40,
                          fit: BoxFit.contain,
                        ))
                  ],
                ))));
  }

  static Widget buildSeeAllBookmarksCard(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(BookmarksScreen.route);
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18.0)),
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
              width: 0.35 * width,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text('Vezi toate obiectivele salvate',
                              textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Theme.of(context).primaryColor))),
                    ),
                  )
                ],
              ),
            )));
  }

  static Widget buildSmallObjectiveCarouselCard(BuildContext context, Objective objective) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: InkWell(
            onTap: () {
              var objectiveInfo = new ObjectiveInfo(objective: objective, fromRoute: ModalRoute.of(context).settings.name);
              Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo);
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
                width: width,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                        child: ClipRRect(
                                          child: Image.asset(
                                            'assets/images/bisericalemn_000.jpg',
                                            fit: BoxFit.cover,
                                            height: double.infinity,
                                          ),
                                          borderRadius: BorderRadius.circular(18),
                                        )),
                                    flex: 1)
                              ],
                            ),
                            flex: 12),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(objective.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline5),
                          ),
                          flex: 6,
                        )
                      ],
                    ),
                    Align(
                        alignment: FractionalOffset(0.5, 0.65),
                        child: Image.asset(
                          'assets/icons/church_marker.png',
                          height: 40,
                          width: 40,
                          fit: BoxFit.contain,
                        ))
                  ],
                ))));
  }

  static Widget buildSmallObjectiveCardC(BuildContext context, Objective objective) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: InkWell(
            onTap: () {
              var objectiveInfo = new ObjectiveInfo(objective: objective, fromRoute: ModalRoute.of(context).settings.name);
              Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo);
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
                width: 0.35 * width,
                height: 0.275 * height,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                child: ClipRRect(
                                  child: Image.asset(
                                    'assets/images/bisericalemn_000.jpg',
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                )),
                            flex: 2),
                        Container(
                            height: 1 / 10 * height,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Text(objective.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline4)))
                      ],
                    ),
                    Positioned(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/church_marker.png',
                            height: 40,
                            width: 40,
                            fit: BoxFit.contain,
                          )
                        ],
                      ),
                      width: width * 0.35,
                      top: height * 0.1375,
                    ),
                  ],
                ))));
  }

  static buildLargeObjectiveCard(BuildContext context, Objective objective) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    var user = Provider.of<AuthenticatedUser>(context);
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: InkWell(
            onTap: () {},
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
                height: height * 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                            child: ClipRRect(
                              child: Image.asset('assets/images/bisericalemn_000.jpg', fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(18 + .0),
                            )),
                        flex: 1),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            child: Column(
                              children: [
                                Row(children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        objective.name,
                                        style: Theme.of(context).textTheme.bodyText1,
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 3),
                                          child: Container(
                                              child: OutlinedButton(
                                                  onPressed: () async {
                                                    Navigator.pushNamed(context, RoutesScreen.route, arguments: objective);
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                      backgroundColor: Colors.white,
                                                      textStyle: TextStyle(fontSize: 14),
                                                      primary: Theme.of(context).primaryColor,
                                                      side: BorderSide(style: BorderStyle.solid, color: Theme.of(context).primaryColor, width: 1),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
                                                  child: Text(context.read<LanguageManager>().routes)))))
                                ]),
                                Row(children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Loredsadasdasm ipsum dolor sit amet, onsectetur adipiscing elit. Curabitur risus ligula",
                                        style: Theme.of(context).textTheme.bodyText2,
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 3),
                                          child: Container(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                var objectiveInfo = new ObjectiveInfo(objective: objective, fromRoute: ModalRoute.of(context).settings.name);
                                                Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo);
                                              },
                                              child: Text(context.read<LanguageManager>().details),
                                              style: ElevatedButton.styleFrom(
                                                  textStyle: TextStyle(fontSize: 14.0),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
                                            ),
                                          )))
                                ])
                              ],
                            )),
                        flex: 1)
                  ],
                ))));
  }

  static buildNearestObjectiveButton(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
            height: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 10,
                ),
                Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      child: Text(
                        'Vezi toate obiectivele pe harta',
                        style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
                        textAlign: TextAlign.start,
                      ),
                      onTap: () {
                        context.read<MainBloc>().objectiveEventSync.add(Constants.NavigateToExplore);
                      },
                    )),
              ],
            )));
  }

  static buildShimmerRouteCard(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(18.0)),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
            height: height * 0.3,
            child: Column(children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                      child: Column(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: ClipRRect(
                                        child: Padding(
                                          child: Shimmer.fromColors(
                                              highlightColor: Colors.white,
                                              baseColor: Colors.black26,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black26,
                                                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                                ),
                                              )),
                                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 5),
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      flex: 1),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                        child: Container(
                                            width: 3,
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black12,
                                                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                                  ),
                                                  height: 10,
                                                ),
                                              ),
                                              Spacer(
                                                flex: 1,
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black12,
                                                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                                  ),
                                                  height: 10,
                                                ),
                                              ),
                                              Spacer(
                                                flex: 1,
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black12,
                                                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                                  ),
                                                  height: 10,
                                                ),
                                              ),
                                              Spacer(
                                                flex: 5,
                                              ),
                                            ])),
                                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0)),
                                  ),
                                ],
                              )),
                          Expanded(
                              flex: 1,
                              child: Container(
                                child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 2,
                                              child: Container(
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: Colors.black12,
                                                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                                ),
                                              )),
                                          Spacer(flex: 1),
                                          Expanded(
                                              flex: 2,
                                              child: Container(
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: Colors.black12,
                                                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                                ),
                                              )),
                                          Spacer(flex: 1),
                                          Expanded(
                                              flex: 2,
                                              child: Container(
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: Colors.black12,
                                                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                                ),
                                              ))
                                        ],
                                      )
                                    ])),
                              ))
                        ],
                      )),
                  flex: 1)
            ])));
  }

  static buildRouteCard(BuildContext context, BikeRoute route) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(18.0)),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
            height: height * 0.3,
            child: Column(children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                      child: Column(
                        children: [
                          Expanded(
                              flex: 20,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: ClipRRect(
                                        child: Image.asset('assets/images/bisericalemn_000.jpg', fit: BoxFit.cover),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      flex: 1),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                        child: Container(
                                            width: 3,
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              Text(
                                                route.name,
                                                style: Theme.of(context).textTheme.headline5,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                route.description,
                                                style: Theme.of(context).textTheme.bodyText2,
                                              )
                                            ])),
                                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0)),
                                  ),
                                ],
                              )),
                          Expanded(
                              flex: 8,
                              child: Container(
                                child: buildRouteStats(context, route),
                              ))
                        ],
                      )),
                  flex: 1)
            ])));
  }

  static buildRouteStats(BuildContext context, BikeRoute route) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: InkWell(
                    onTap: () async {},
                    child: Column(
                      children: [
                        Text(context.read<LanguageManager>().routeDistance, style: Theme.of(context).textTheme.bodyText2),
                        SizedBox(height: 3),
                        Text(route.distance.toString() + ' KM', style: Theme.of(context).textTheme.bodyText1)
                      ],
                    )),
                flex: 7),
            Expanded(
                child: InkWell(
                    onTap: () async {},
                    child: Column(
                      children: [
                        Text(context.read<LanguageManager>().objective, style: Theme.of(context).textTheme.bodyText2),
                        SizedBox(height: 3),
                        Text(route.objectives.length.toString(), style: Theme.of(context).textTheme.bodyText1)
                      ],
                    )),
                flex: 7),
            Spacer(flex: 3),
            Expanded(
                child: InkWell(
                  onTap: () async {},
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
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
                          database.update('route', {'rating': serverRoute.rating, 'rating_count': serverRoute.ratingCount},
                              where: 'id = ?', whereArgs: [bikeRoute.id]);
                          bikeRoute.rating = serverRoute.rating;
                          bikeRoute.ratingCount = serverRoute.ratingCount;
                          bikeRoute.commentCount = serverRoute.commentCount;
                        }

                        Navigator.of(context).pushNamed(MapScreen.route, arguments: bikeRoute);
                      } on Exception catch (e) {
                        print(e);
                      }
                    },
                    child: Text(context.read<LanguageManager>().details),
                    style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(fontSize: 14.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
                  ),
                ),
                flex: 10)
          ],
        )
      ],
    );
  }
}
