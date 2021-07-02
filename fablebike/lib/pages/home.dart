import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:latlong/latlong.dart';
import 'package:fablebike/widgets/card_builders.dart';

import 'package:fablebike/services/math_service.dart' as mapMath;

LatLng myLocation = LatLng(46.45447, 27.72501);

class HomeScreen extends StatefulWidget {
  static const String route = '/home';
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String route = '/home';
  Future<List<PointOfInterest>> _getBookmarks(AuthenticatedUser user) async {
    var db = await DatabaseService().database;

    var poiRows = await db.rawQuery('SELECT * FROM pointofinterestbookmark pb INNER JOIN pointofinterest p ON p.id = pb.poi_id WHERE pb.user_id = ${user.id}');
    var pois = List.generate(poiRows.length, (i) => PointOfInterest.fromJson(poiRows[i]));
    return pois;
  }

  Future<List<PointOfInterest>> _getNearbyPOI(AuthenticatedUser user) async {
    var db = await DatabaseService().database;

    var bookmarkRows =
        await db.rawQuery('SELECT * FROM pointofinterestbookmark pb INNER JOIN pointofinterest p ON p.id = pb.poi_id WHERE pb.user_id = ${user.id}');
    var bookmarks = List.generate(bookmarkRows.length, (i) => PointOfInterest.fromJson(bookmarkRows[i]));

    var poiRows = await db.query('pointofinterest');
    var pois = List.generate(poiRows.length, (i) => PointOfInterest.fromJson(poiRows[i]));

    if (bookmarks.length > 0) {
      pois.forEach((element) {
        element.is_bookmarked = bookmarks.where((el) => el.id == element.id).isNotEmpty;
      });
    }
    return pois.where((c) => mapMath.calculateDistance(myLocation.latitude, myLocation.longitude, c.latitude, c.longitude) < 10).toList();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthenticatedUser>(context);
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
          bottomNavigationBar: buildBottomBar(context, route),
          appBar: AppBar(
            title: Center(
                child: Text(
              'Acasa',
              style: Theme.of(context).textTheme.headline3,
            )),
            shadowColor: Colors.white54,
            backgroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 25),
                      _buildStatsRow(context),
                      SizedBox(height: 25),
                      FutureBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return CardBuilder.buildAnnouncementBanner(context);
                              } else {
                                return CircularProgressIndicator();
                              }
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                          future: _getNearbyPOI(user)),
                      SizedBox(height: 25),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                        child: Row(children: [
                          Icon(Icons.bookmark_border_outlined),
                          SizedBox(width: 5),
                          Text(
                            'Puncte de interes marcate',
                            style: Theme.of(context).textTheme.headline5,
                            textAlign: TextAlign.start,
                          )
                        ]),
                      ),
                      SizedBox(height: 25),
                      FutureBuilder<List<PointOfInterest>>(
                          builder: (context, AsyncSnapshot<List<PointOfInterest>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: snapshot.data.length == 0
                                        ? [Text('Nu aveti niciun punct de interes salvat.')]
                                        : List.generate(snapshot.data.length, (index) {
                                            return CardBuilder.buildSmallPOICard(context, snapshot.data[index]);
                                          }),
                                  ),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                          future: _getBookmarks(user)),
                      SizedBox(height: 25),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                        child: Row(children: [
                          Icon(Icons.fmd_good),
                          SizedBox(width: 5),
                          Text(
                            'Puncte de interes aflate in apropiere',
                            style: Theme.of(context).textTheme.headline5,
                            textAlign: TextAlign.start,
                          )
                        ]),
                      ),
                      SizedBox(height: 25),
                      FutureBuilder<List<PointOfInterest>>(
                          builder: (context, AsyncSnapshot<List<PointOfInterest>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data != null) {
                                List<Widget> widgets = List.generate(snapshot.data.length > 5 ? 5 : snapshot.data.length, (index) {
                                  return CardBuilder.buildLargePOICard(context, snapshot.data[index]);
                                });
                                widgets.add(CardBuilder.buildNearestPoiButton(context));
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
                          future: _getNearbyPOI(user)),
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
                          Text('Distanta parcursa', style: Theme.of(context).textTheme.bodyText2),
                          SizedBox(height: 3),
                          Text('2000 Km', style: Theme.of(context).textTheme.bodyText1)
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
                          Text('Rute finalizate', style: Theme.of(context).textTheme.bodyText2),
                          SizedBox(height: 3),
                          Text('3 Km', style: Theme.of(context).textTheme.bodyText1)
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
                          Text('Puncte vizitate', style: Theme.of(context).textTheme.bodyText2),
                          SizedBox(height: 3),
                          Text('450', style: Theme.of(context).textTheme.bodyText1)
                        ],
                      )),
                  flex: 1)
            ],
          )
        ],
      ));
}
