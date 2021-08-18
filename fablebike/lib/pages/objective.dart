import 'dart:math';
import 'dart:ui';
import 'package:fablebike/bloc/event_constants.dart';
import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/card_builders.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

class ObjectiveScreen extends StatefulWidget {
  static const route = 'objective';
  final String fromRoute;

  final Objective objective;
  ObjectiveScreen({Key key, @required this.objective, this.fromRoute}) : super(key: key);

  @override
  _ObjectiveScreenState createState() => _ObjectiveScreenState();
}

class _ObjectiveScreenState extends State<ObjectiveScreen> {
  bool is_bookmarked = false;
  Future<bool> _getObjectiveData(int userId, int objectiveId) async {
    var db = await DatabaseService().database;

    var rows = await db.query('objectivebookmark', where: 'user_id = ? and objective_id = ?', whereArgs: [userId, objectiveId]);
    this.is_bookmarked = rows.length > 0;
    return rows.length > 0;
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 3000);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    var user = Provider.of<AuthenticatedUser>(context);
    double smallDivider = 10.0;
    double bigDivider = 20.0;

    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SafeArea(
          child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: SingleChildScrollView(
                  child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                          child: ClipRRect(
                        child: Hero(
                            child: Container(
                              height: height * 0.6,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(0.0), bottomRight: Radius.circular(0.0)),
                                  image: new DecorationImage(
                                    image: Image.asset('assets/images/bisericalemn_000.jpg').image,
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.025), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                              width: width,
                            ),
                            tag: 'objective-hero' + widget.objective.name),
                      )),
                      Hero(
                          child: Container(
                            height: height * 0.6,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                color: Colors.white,
                                gradient: LinearGradient(begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter, colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.black.withOpacity(0.5),
                                ], stops: [
                                  0.5,
                                  0.75
                                ]),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.025), spreadRadius: 2, blurRadius: 6, offset: Offset(0, 0))]),
                            width: width,
                          ),
                          tag: 'obj-layer' + widget.objective.name),
                      Positioned(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0))),
                        ),
                        height: 12,
                        width: width,
                        bottom: 0,
                      ),
                      Positioned(
                          child: InkWell(
                        child: Icon(Icons.exit_to_app),
                        onTap: () => Navigator.pop(context),
                      )),
                      Positioned(
                          child: Hero(
                              child: Container(
                                width: width,
                                height: 96,
                                child: Column(children: [
                                  Spacer(flex: 1),
                                  Expanded(
                                      child: Row(
                                        children: [
                                          Icon(Icons.cottage, color: Colors.white),
                                        ],
                                      ),
                                      flex: 6),
                                  Expanded(
                                      child: Row(
                                        children: [
                                          Text('Biserica de lemn',
                                              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: Colors.white)),
                                        ],
                                      ),
                                      flex: 8),
                                  Expanded(
                                      child: Row(
                                        children: [
                                          CardBuilder.buildStars(context, 3, true),
                                          SizedBox(width: 5),
                                          Text('4.5 (10)', style: TextStyle(fontSize: 12.0, color: Colors.white))
                                        ],
                                      ),
                                      flex: 4),
                                ]),
                              ),
                              tag: 'obj-desc' + widget.objective.name),
                          bottom: 32,
                          left: 20),
                    ],
                  ),
                  Padding(
                    child: Column(
                      children: [
                        Row(children: [
                          Text(
                            "Descriere",
                            style: Theme.of(context).textTheme.headline2,
                            textAlign: TextAlign.start,
                          )
                        ]),
                        SizedBox(height: smallDivider),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 2.0),
                  )
                ],
              ))),
        ));
  }
}
