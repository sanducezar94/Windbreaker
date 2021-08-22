import 'dart:math';
import 'dart:ui';
import 'package:fablebike/bloc/event_constants.dart';
import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/objective_header_delegate.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/card_builders.dart';
import 'package:fablebike/widgets/routes_carousel.dart';
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
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: Stack(
                    fit: StackFit.expand,
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
                        bottom: -6,
                      ),
                      Positioned(
                          top: 84,
                          left: 20,
                          child: InkWell(
                            child: Container(
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.45)),
                              width: 48,
                              height: 48,
                              child: Icon(Icons.arrow_back, color: Colors.white),
                            ),
                            onTap: () => Navigator.pop(context),
                          )),
                      Positioned(
                          top: 84,
                          right: 20,
                          child: InkWell(
                            child: Container(
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.45)),
                              width: 48,
                              height: 48,
                              child: Icon(Icons.share, color: Colors.white),
                            ),
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
                  height: height * 0.65,
                  width: 999,
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
                        SizedBox(height: bigDivider),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                                text:
                                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequa',
                                style: Theme.of(context).textTheme.subtitle2),
                            maxLines: 15,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(height: bigDivider),
                        Row(children: [
                          Text(
                            "Trasee catre obiectiv",
                            style: Theme.of(context).textTheme.headline2,
                            textAlign: TextAlign.start,
                          )
                        ]),
                        Container(
                          child: RouteCarousel(
                            context: context,
                            routes: [],
                            width: width * 0.45,
                          ),
                          height: height * 0.45,
                          width: 999,
                        ),
                        Row(children: [
                          Text(
                            "Poze",
                            style: Theme.of(context).textTheme.headline2,
                            textAlign: TextAlign.start,
                          )
                        ]),
                        SizedBox(height: bigDivider),
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                      child: Column(
                                        children: [
                                          Container(
                                            child: ClipRRect(
                                                child: Image.asset('assets/icons/route.png', width: width * 0.5, height: height * 0.175, fit: BoxFit.cover),
                                                borderRadius: BorderRadius.circular(12.0)),
                                            decoration: BoxDecoration(boxShadow: [
                                              BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))
                                            ]),
                                          ),
                                          SizedBox(height: bigDivider),
                                          Container(
                                            child: ClipRRect(
                                                child: Image.asset('assets/icons/route.png', width: width * 0.5, height: height * 0.35, fit: BoxFit.cover),
                                                borderRadius: BorderRadius.circular(12.0)),
                                            decoration: BoxDecoration(boxShadow: [
                                              BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))
                                            ]),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.fromLTRB(0, 4, 8, 0))),
                              Expanded(
                                  child: Padding(
                                      child: Column(
                                        children: [
                                          SizedBox(height: bigDivider * 2),
                                          Container(
                                            child: ClipRRect(
                                                child: Image.asset('assets/icons/route.png', width: width * 0.5, height: height * 0.35, fit: BoxFit.cover),
                                                borderRadius: BorderRadius.circular(12.0)),
                                            decoration: BoxDecoration(boxShadow: [
                                              BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))
                                            ]),
                                          ),
                                          SizedBox(height: bigDivider),
                                          Container(
                                            child: ClipRRect(
                                                child: Stack(
                                                  children: [
                                                    Image.asset('assets/icons/route.png', width: width * 0.5, height: height * 0.175, fit: BoxFit.cover),
                                                    Container(
                                                      height: height * 0.175,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                                          color: Colors.white,
                                                          gradient:
                                                              LinearGradient(begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter, colors: [
                                                            Colors.black.withOpacity(0.25),
                                                            Colors.black.withOpacity(0.75),
                                                          ], stops: [
                                                            0,
                                                            1
                                                          ]),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors.black.withOpacity(0.025), spreadRadius: 2, blurRadius: 6, offset: Offset(0, 0))
                                                          ]),
                                                      width: width,
                                                    ),
                                                    Container(
                                                      height: height * 0.175,
                                                      width: width * 0.5,
                                                      child: Align(
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          '+6 Poze',
                                                          style: Theme.of(context).textTheme.headline3,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(12.0)),
                                            decoration: BoxDecoration(boxShadow: [
                                              BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))
                                            ]),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.fromLTRB(8, 4, 0, 0)))
                            ],
                          ),
                          width: 999,
                          height: bigDivider * 1 + height * 0.65,
                        ),
                        Row(children: [
                          Text(
                            "Contact",
                            style: Theme.of(context).textTheme.headline2,
                            textAlign: TextAlign.start,
                          )
                        ]),
                        SizedBox(height: bigDivider),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Image.asset('assets/icons/fb_h.png'),
                                    ),
                                    flex: 1),
                                Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Image.asset('assets/icons/web_h.png'),
                                    ),
                                    flex: 1),
                                Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Image.asset('assets/icons/phone_h.png'),
                                    ),
                                    flex: 1),
                                Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Image.asset('assets/icons/mail.png'),
                                    ),
                                    flex: 1),
                                Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Image.asset('assets/icons/insta.png'),
                                    ),
                                    flex: 1),
                                Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Image.asset('assets/icons/yt.png'),
                                    ),
                                    flex: 1),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: bigDivider,
                        ),
                        Row(children: [
                          Text(
                            "www.bisericadepedeal.ro",
                            style: TextStyle(fontSize: 18.0, color: Theme.of(context).primaryColorDark),
                            textAlign: TextAlign.start,
                          )
                        ]),
                        SizedBox(height: smallDivider),
                        Row(children: [
                          Text(
                            "+40 7555 123 455",
                            style: TextStyle(fontSize: 18.0, color: Theme.of(context).primaryColorDark),
                            textAlign: TextAlign.start,
                          )
                        ]),
                        SizedBox(height: smallDivider),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0)),
              ],
            ),

            /*SliverList(
                    delegate: SliverChildListDelegate([

                    ]),
                  )*/
          )),
    );
  }
}
