import 'dart:ui';

import 'package:fablebike/models/route.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';

class POIScreen extends StatefulWidget {
  static const route = 'poi';

  final PointOfInterest poi;
  POIScreen({Key key, @required this.poi}) : super(key: key);

  @override
  _POIScreenState createState() => _POIScreenState();
}

class _POIScreenState extends State<POIScreen> {
  @override
  Widget build(BuildContext context) {
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
                      InkWell(
                        child: widget.poi.is_bookmarked ? Icon(Icons.bookmark) : Icon(Icons.bookmark_add_outlined),
                        onTap: () async {
                          var db = await DatabaseService().database;
                          widget.poi.is_bookmarked = !widget.poi.is_bookmarked;
                          await db.update('pointofinterest', {'is_bookmarked': widget.poi.is_bookmarked}, where: 'id = ?', whereArgs: [widget.poi.id]);

                          this.setState(() {});
                        },
                      ),
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
