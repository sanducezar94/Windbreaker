import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/bloc/bookmarks_bloc.dart';
import 'package:fablebike/bloc/event_constants.dart';
import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:latlong/latlong.dart';
import 'package:fablebike/widgets/card_builders.dart';

import 'package:fablebike/services/math_service.dart' as mapMath;
import 'package:sqflite/sqflite.dart';

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

  Future<List<Objective>> _getNearbyObjectives(AuthenticatedUser user) async {
    var db = await DatabaseService().database;

    var bookmarkRows = await db.rawQuery('SELECT * FROM objectivebookmark pb INNER JOIN objective p ON p.id = pb.objective_id WHERE pb.user_id = ${user.id}');
    var bookmarks = List.generate(bookmarkRows.length, (i) => Objective.fromJson(bookmarkRows[i]));

    var objectiveRows = await db.query('Objective');
    var objectives = List.generate(objectiveRows.length, (i) => Objective.fromJson(objectiveRows[i]));

    if (bookmarks.length > 0) {
      objectives.forEach((element) {
        element.is_bookmarked = bookmarks.where((el) => el.id == element.id).isNotEmpty;
      });
    }
    return objectives.where((c) => mapMath.calculateDistance(myLocation.latitude, myLocation.longitude, c.latitude, c.longitude) < 10).toList();
  }

  @override
  initState() {
    super.initState();
    user = context.read<AuthenticatedUser>();
    subscription = context.read<MainBloc>().output.listen((event) {
      if (event == Constants.HomeRefreshBookmarks) {
        _bloc.bookmarkEventSync.add(BookmarkBlocEvent(eventType: BookmarkEventType.BookmarkInitializeEvent, args: {'user_id': user.id}));
      }
    });

    _bloc.bookmarkEventSync.add(BookmarkBlocEvent(eventType: BookmarkEventType.BookmarkInitializeEvent, args: {'user_id': user.id}));
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
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
          appBar: AppBar(
            title: Center(
                child: Text(
              context.read<LanguageManager>().appHome,
              style: Theme.of(context).textTheme.headline3,
            )),
            shadowColor: Colors.white10,
            backgroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Column(
                    children: [
                      //SizedBox(height: 25),
                      // _buildStatsRow(context),
                      // SizedBox(height: 25),
                      FutureBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return CardBuilder.buildAnnouncementBanner(context);
                              } else {
                                return CardBuilder.buildAnnouncementBannerShimmer(context);
                              }
                            } else {
                              return CardBuilder.buildAnnouncementBannerShimmer(context);
                            }
                          },
                          future: _getNearbyObjectives(user)),
                      SizedBox(height: 25),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                        child: Row(children: [
                          Icon(Icons.bookmarks_outlined),
                          SizedBox(width: 5),
                          Text(
                            context.read<LanguageManager>().homeBookmarks,
                            style: Theme.of(context).textTheme.headline5,
                            textAlign: TextAlign.start,
                          )
                        ]),
                      ),
                      SizedBox(height: 25),
                      StreamBuilder(
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.length == 0)
                              return Padding(
                                child: Row(
                                  children: [Text('Nu aveti puncte de interest salvate.', style: Theme.of(context).textTheme.headline4)],
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                              );
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.275,
                              child: ListView.separated(
                                  itemBuilder: (context, index) => (index == 5 || index == snapshot.data.length + 1)
                                      ? CardBuilder.buildSeeAllBookmarksCard(context)
                                      : CardBuilder.buildSmallObjectiveCard(context, snapshot.data[index]),
                                  padding: EdgeInsets.all(0),
                                  separatorBuilder: (context, index) => Divider(
                                        indent: 0,
                                        thickness: 0,
                                        endIndent: 0,
                                      ),
                                  itemCount: min(6, snapshot.data.length),
                                  scrollDirection: Axis.horizontal),
                            );
                          } else {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.275,
                              child: ListView.separated(
                                  itemBuilder: (context, index) => CardBuilder.buildSmallObjectiveShimmerCard(context),
                                  padding: EdgeInsets.all(0),
                                  separatorBuilder: (context, index) => Divider(
                                        indent: 0,
                                        thickness: 0,
                                        endIndent: 0,
                                      ),
                                  itemCount: 5,
                                  scrollDirection: Axis.horizontal),
                            );
                          }
                        },
                        initialData: null,
                        stream: _bloc.output,
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                        child: Row(children: [
                          Icon(Icons.fmd_good),
                          SizedBox(width: 5),
                          Text(
                            context.read<LanguageManager>().homeNearbyObjectives,
                            style: Theme.of(context).textTheme.headline5,
                            textAlign: TextAlign.start,
                          )
                        ]),
                      ),
                      SizedBox(height: 25),
                      FutureBuilder<List<Objective>>(
                          builder: (context, AsyncSnapshot<List<Objective>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data != null) {
                                List<Widget> widgets = List.generate(snapshot.data.length > 5 ? 5 : snapshot.data.length, (index) {
                                  return CardBuilder.buildLargeObjectiveCard(context, snapshot.data[index]);
                                });
                                widgets.add(CardBuilder.buildNearestObjectiveButton(context));
                                return SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(children: widgets),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                          future: _getNearbyObjectives(user)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

_buildStatsRow(BuildContext context) {
  return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: InkWell(
                      onTap: () async {},
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/icons/dt.png',
                            fit: BoxFit.contain,
                            height: 48,
                          ),
                          SizedBox(height: 5),
                          Text(context.read<LanguageManager>().homeDistance, style: Theme.of(context).textTheme.bodyText2),
                          SizedBox(height: 3),
                          Text(context.read<AuthenticatedUser>().distanceTravelled.toString() + ' Km', style: Theme.of(context).textTheme.bodyText1)
                        ],
                      )),
                  flex: 1),
              Expanded(
                  child: InkWell(
                      onTap: () async {},
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/icons/rf.png',
                            fit: BoxFit.contain,
                            height: 48,
                          ),
                          SizedBox(height: 5),
                          Text(context.read<LanguageManager>().homeRoutes, style: Theme.of(context).textTheme.bodyText2),
                          SizedBox(height: 3),
                          Text(context.read<AuthenticatedUser>().finishedRoutes.toString(), style: Theme.of(context).textTheme.bodyText1)
                        ],
                      )),
                  flex: 1),
              Expanded(
                  child: InkWell(
                      onTap: () async {},
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/icons/pv.png',
                            fit: BoxFit.contain,
                            height: 48,
                          ),
                          SizedBox(height: 5),
                          Text(context.read<LanguageManager>().homeObjectives, style: Theme.of(context).textTheme.bodyText2),
                          SizedBox(height: 3),
                          Text(context.read<AuthenticatedUser>().objectivesVisited.toString(), style: Theme.of(context).textTheme.bodyText1)
                        ],
                      )),
                  flex: 1)
            ],
          )
        ],
      ));
}
