import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/carousel.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:provider/provider.dart';
import '../widgets/drawer.dart';

class HomeScreen extends StatelessWidget {
  static const String route = '/home';

  Future<List<PointOfInterest>> _getBookmarks() async {
    var db = await DatabaseService().database;

    var poiRows = await db.query('pointofinterest', where: 'is_bookmarked = 1');

    var pois = List.generate(poiRows.length, (i) => PointOfInterest.fromJson(poiRows[i]));

    return pois;
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthenticatedUser>(context);
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
          appBar: AppBar(title: Text('Home')),
          drawer: buildDrawer(context, route),
          body: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      verticalDirection: VerticalDirection.up,
                      children: [Text('Hello ' + user.username)],
                    ),
                    Container(
                      child: FutureBuilder<List<PointOfInterest>>(
                          builder: (BuildContext context, AsyncSnapshot<List<PointOfInterest>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData) {
                                return Carousel(
                                  pois: snapshot.data,
                                  context: context,
                                );
                              } else {
                                return Text('Nu ai niciun punct de interes favorit.');
                              }
                            } else {
                              return Text('Nu ai niciun punct de interes favorit.');
                            }
                          },
                          future: this._getBookmarks()),
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, ImagePickerScreen.route);
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
