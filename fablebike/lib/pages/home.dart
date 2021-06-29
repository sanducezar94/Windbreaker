import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/carousel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/drawer.dart';
import 'package:latlong/latlong.dart';

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

    var poiRows = await db.query('pointofinterest');
    var pois = List.generate(poiRows.length, (i) => PointOfInterest.fromJson(poiRows[i]));
    return pois.where((c) => mapMath.calculateDistance(myLocation.latitude, myLocation.longitude, c.latitude, c.longitude) < 10).toList();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthenticatedUser>(context);
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Acasa'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          drawer: buildDrawer(context, route),
          body: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Column(
                  children: [
                    SizedBox(height: 15),
                    _buildStatsRow(context),
                    SizedBox(height: 15),
                    FutureBuilder(
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return _buildAnnouncementBanner(context);
                            } else {
                              return CircularProgressIndicator();
                            }
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                        future: _getNearbyPOI(user)),
                    SizedBox(height: 20),
                    Row(
                      verticalDirection: VerticalDirection.up,
                      children: [Text('Puncte de interes aflate in apropiere. ' + user.username)],
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: FutureBuilder<List<PointOfInterest>>(
                          builder: (BuildContext context, AsyncSnapshot<List<PointOfInterest>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData) {
                                return Carousel(
                                  pois: snapshot.data,
                                  context: context,
                                  onPageClosed: () {
                                    setState(() {});
                                  },
                                );
                              } else {
                                return Text('Nu este niciun punct de interes in apropiere.');
                              }
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                          future: this._getNearbyPOI(user)),
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, ImagePickerScreen.route).then((value) {
                                setState(() {});
                              });
                            },
                            child: Icon(Icons.add_a_photo))
                      ],
                    )
                  ],
                ),
              ],
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
                            'assets/images/user (1).png',
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
                            'assets/images/user (1).png',
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
                            'assets/images/user (1).png',
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

_buildAnnouncementBanner(BuildContext context) {
  return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 5, blurRadius: 7, offset: Offset(0, 9))]),
        width: 1024,
        height: 128,
        child: Column(
          children: [
            SizedBox(height: 10.0),
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
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6.0),
                    child: Text(
                      'Anunt Important',
                      style: Theme.of(context).textTheme.headline2,
                    ))
              ],
            )
          ],
        ),
      ));
}
