import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/bloc/bookmarks_bloc.dart';
import 'package:fablebike/bloc/event_constants.dart';
import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/bloc/objective_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';
import 'package:latlong/latlong.dart';
import 'package:fablebike/widgets/card_builder.dart';

LatLng myLocation = LatLng(46.45447, 27.72501);

class HomeScreen extends StatefulWidget {
  static const String route = '/home';
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String route = '/home';
  StreamSubscription<String> subscription;
  AuthenticatedUser user;
  final _bloc = BookmarkBloc();
  final _objectiveBloc = ObjectiveBloc();

  Future<List<BikeRoute>> _getRecentRoutes(AuthenticatedUser user) async {
    var db = await DatabaseService().database;

    var routeRows = await db.query('route');
    var routes = List.generate(routeRows.length, (index) => BikeRoute.fromJson(routeRows[index]));

    return [];
  }

  @override
  initState() {
    super.initState();
    Loader.hide();
    user = context.read<AuthenticatedUser>();
    subscription = context.read<MainBloc>().output.listen((event) {
      if (event == Constants.HomeRefreshBookmarks) {
        _bloc.bookmarkEventSync.add(BookmarkBlocEvent(eventType: BookmarkEventType.BookmarkInitializeEvent, args: {'user_id': user.id}));
        _objectiveBloc.objectiveEventSync
            .add(ObjectiveBlocEvent(eventType: ObjectiveEventType.ObjectiveGetNearby, args: {'user_id': user.id, 'location': myLocation}));
      }
    });

    _bloc.bookmarkEventSync.add(BookmarkBlocEvent(eventType: BookmarkEventType.BookmarkInitializeEvent, args: {'user_id': user.id}));
    _objectiveBloc.objectiveEventSync
        .add(ObjectiveBlocEvent(eventType: ObjectiveEventType.ObjectiveGetNearby, args: {'user_id': user.id, 'location': myLocation}));
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
    if (subscription != null) subscription.cancel();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (subscription != null) subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var height = max(656, MediaQuery.of(context).size.height - 80);
    var width = MediaQuery.of(context).size.width - 80;
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
                child: Column(
                  children: [
                    CardBuilder.buildProfileBar(context, 'Acasa', 'Bine ai venit, Cezar!'),
                    SizedBox(height: bigDivider),
                    Row(children: [
                      Text(
                        "Obiective salvate",
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.start,
                      )
                    ]),
                    SizedBox(height: smallDivider),
                    StreamBuilder(
                      builder: (BuildContext context, AsyncSnapshot<List<Objective>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.length == 0)
                            return Row(
                              children: [Text('Nu aveti niciun obiectiv salvat.', style: Theme.of(context).textTheme.subtitle1)],
                            );

                          return Container(
                              height: height * 0.275,
                              width: 999,
                              child: Carousel(
                                objectives: snapshot.data,
                                context: context,
                                width: width,
                              ));
                        } else
                          return Container();
                      },
                      initialData: null,
                      stream: _bloc.output,
                    ),
                    SizedBox(height: bigDivider),
                    Row(children: [
                      Text(
                        "Obiective aflate in apropiere",
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.start,
                      ),
                    ]),
                    SizedBox(
                      height: smallDivider,
                    ),
                    StreamBuilder(
                      builder: (BuildContext context, AsyncSnapshot<List<Objective>> snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Container(
                              height: height * 0.275,
                              width: 999,
                              child: Carousel(
                                objectives: snapshot.data,
                                context: context,
                                width: width,
                              ));
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                      initialData: null,
                      stream: _objectiveBloc.output,
                    ),
                    SizedBox(height: bigDivider),
                    Row(children: [
                      Text(
                        "Trasee vizitate recent",
                        style: Theme.of(context).textTheme.headline2,
                        textAlign: TextAlign.start,
                      ),
                    ]),
                    SizedBox(
                      height: smallDivider,
                    ),
                    FutureBuilder<List<BikeRoute>>(
                        builder: (context, AsyncSnapshot<List<BikeRoute>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData && snapshot.data != null) {
                              if (snapshot.data.length == 0)
                                return Column(
                                  children: [
                                    Row(
                                      children: [Text('Nu ati fost pe niciun traseu recent.', style: Theme.of(context).textTheme.subtitle1)],
                                    ),
                                    SizedBox(
                                      height: smallDivider,
                                    ),
                                    Row(
                                      children: [Text('Vezi toate traseele', style: TextStyle(color: Theme.of(context).primaryColorDark, fontSize: 18.0))],
                                    )
                                  ],
                                );
                              return Column(
                                children: [
                                  for (var i = 0; i < 3; i++)
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Container(
                                        child: CardBuilder.buildBigRouteCard(context, snapshot.data[i]),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                                                  spreadRadius: 16,
                                                  blurRadius: 12,
                                                  offset: Offset(0, 13))
                                            ]),
                                      ),
                                    ),
                                  SizedBox(
                                    height: 10,
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
                        future: _getRecentRoutes(user)),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
