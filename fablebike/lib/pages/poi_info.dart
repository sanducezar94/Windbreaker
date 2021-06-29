import 'dart:ui';

import 'package:fablebike/bloc/bookmarks_bloc.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class POIScreen extends StatefulWidget {
  static const route = 'poi';

  final PointOfInterest poi;
  POIScreen({Key key, @required this.poi}) : super(key: key);

  @override
  _POIScreenState createState() => _POIScreenState();
}

class _POIScreenState extends State<POIScreen> {
  bool is_bookmarked = false;
  Future<bool> _getPoiData(int userId, int poiId) async {
    var db = await DatabaseService().database;

    var rows = await db.query('pointofinterestbookmark', where: 'user_id = ? and poi_id = ?', whereArgs: [userId, poiId]);
    this.is_bookmarked = rows.length > 0;
    return rows.length > 0;
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthenticatedUser>(context);
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [Image.asset('assets/images/bisericalemn_000.jpg', fit: BoxFit.cover)],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      FutureBuilder(
                          builder: (context, AsyncSnapshot<bool> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData) {
                                return InkWell(
                                  child: is_bookmarked ? Icon(Icons.bookmark) : Icon(Icons.bookmark_add_outlined),
                                  onTap: () async {
                                    var db = await DatabaseService().database;
                                    is_bookmarked = !is_bookmarked;

                                    if (is_bookmarked) {
                                      await db.insert('pointofinterestbookmark', {'user_id': user.id, 'poi_id': widget.poi.id});
                                    } else {
                                      await db.delete('pointofinterestbookmark', where: 'user_id = ? and poi_id = ?', whereArgs: [user.id, widget.poi.id]);
                                    }
                                    this.setState(() {});
                                  },
                                );
                              } else {
                                return SizedBox(height: 1);
                              }
                            } else
                              return CircularProgressIndicator();
                          },
                          future: _getPoiData(user.id, widget.poi.id))
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            try {
                              var test = await Share.share('check out my website https://example.com');
                            } on Exception catch (e) {
                              print(e.toString());
                            }
                          },
                          child: Text('Share on fb'))
                    ],
                  ),
                  Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscinLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duig elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam dui')
                ]),
              ),
            ],
          ),
        ));
  }
}
