import 'dart:math';

import 'package:fablebike/bloc/event_constants.dart';
import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/comments.dart';
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
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CardBuilder {
  static double circularRadius = 16.0;
  static Widget buildProfileBar(BuildContext context, String tab, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Row(children: [
                Text(
                  tab,
                  style: Theme.of(context).textTheme.headline1,
                  textAlign: TextAlign.start,
                )
              ]),
              SizedBox(height: 5),
              Row(children: [
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.start,
                )
              ]),
            ],
          ),
          flex: 3,
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(64.0)),
                    color: Theme.of(context).primaryColor.withOpacity(0.25),
                    border: Border.all(color: Color.fromRGBO(232, 242, 243, 1), width: 8)),
              ),
              ClipRRect(
                child: Image.asset('assets/icons/avatar_icon.png', width: 64, height: 64, fit: BoxFit.contain),
                borderRadius: BorderRadius.circular(48.0),
              )
            ],
          ),
          flex: 1,
        )
      ],
    );
  }

  static Widget buildStars(BuildContext context, rating, applyShadow, {double opacity: 1}) {
    return Row(children: [
      for (var i = 0; i < 5; i++)
        Container(
          decoration: applyShadow
              ? BoxDecoration(color: Colors.white.withOpacity(0), shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: .5,
                  ),
                ])
              : null,
          child: Icon(
            Icons.star,
            color: rating >= i ? Color.fromRGBO(255, 196, 107, 1).withOpacity(opacity) : Colors.grey.withOpacity(opacity),
            size: 18,
          ),
        )
    ]);
  }

  static Widget buildSmallObjectiveCarouselCard(BuildContext context, int index, Objective objective, bool noInfo) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return Padding(
        padding: index == 0 ? EdgeInsets.fromLTRB(0, 6, 16.0, 6) : EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        child: InkWell(
            onTap: () {
              var objectiveInfo = new ObjectiveInfo(objective: objective, fromRoute: ModalRoute.of(context).settings.name);
              //  Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo);
            },
            child: Stack(
              children: [
                Container(
                  height: 999,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
                      image: new DecorationImage(
                        image: Image.asset('assets/images/bisericalemn_000.jpg').image,
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.025), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                  width: width,
                ),
                Container(
                  height: 999,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
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
                noInfo
                    ? Positioned(
                        bottom: 6,
                        left: 24,
                        child: Container(
                          width: 200,
                          height: 40,
                          child: Column(children: [
                            Expanded(
                                child: Row(
                                  children: [
                                    Text('Biserica de lemn', style: Theme.of(context).textTheme.headline3),
                                  ],
                                ),
                                flex: 6),
                          ]),
                        ),
                      )
                    : Positioned(
                        child: Container(
                          width: 200,
                          height: 75,
                          child: Column(children: [
                            Expanded(
                                child: Row(
                                  children: [buildStars(context, 3, true)],
                                ),
                                flex: 4),
                            Spacer(flex: 1),
                            Expanded(
                                child: Row(
                                  children: [
                                    Text('Biserica de lemn', style: Theme.of(context).textTheme.headline3),
                                  ],
                                ),
                                flex: 6),
                            Expanded(
                                child: Row(
                                  children: [
                                    Text('Scris scris scris scris', style: Theme.of(context).textTheme.headline4),
                                  ],
                                ),
                                flex: 6)
                          ]),
                        ),
                        bottom: 24,
                        left: 24)
              ],
            )));
  }

  static Widget buildlargeObjectiveCard(BuildContext context, Objective objective) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
        child: InkWell(
            onTap: () {
              var objectiveInfo = new ObjectiveInfo(objective: objective, fromRoute: ModalRoute.of(context).settings.name);

              /* Navigator.of(context).push(PageRouteBuilder(
                  transitionDuration: Duration(microseconds: 1000),
                  fullscreenDialog: true,
                  pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                    return ObjectiveScreen(objective: objective);
                  },
                  transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                    return FadeTransition(opacity: animation, child: child);
                  }));*/
              Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo);
            },
            child: Stack(
              children: [
                InkWell(
                    child: Hero(
                        child: Container(
                          height: height * 0.25,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
                              image: new DecorationImage(
                                image: Image.asset('assets/images/bisericalemn_000.jpg').image,
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.025), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                          width: width,
                        ),
                        tag: 'objective-hero' + objective.name),
                    onTap: () {}),
                Hero(
                    child: Container(
                      height: height * 0.25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
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
                    tag: 'obj-layer' + objective.name),
                Positioned(
                    child: Hero(
                        child: Container(
                          width: 200,
                          height: 80,
                          child: Column(children: [
                            Spacer(flex: 6),
                            /* Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.cottage, color: Colors.white),
                                  ],
                                ),
                                flex: 6),*/
                            Expanded(
                                child: Row(
                                  children: [
                                    Text('Biserica de lemn', style: Theme.of(context).textTheme.headline3),
                                  ],
                                ),
                                flex: 6),
                            Expanded(
                                child: Row(
                                  children: [
                                    buildStars(context, 3, true),
                                    SizedBox(width: 5),
                                    Text('4.5 (10)', style: TextStyle(fontSize: 12.0, color: Colors.white))
                                  ],
                                ),
                                flex: 4),
                          ]),
                        ),
                        tag: 'obj-desc' + objective.name),
                    bottom: 16,
                    left: 20)
              ],
            )));
  }

  static Widget buildSmallRouteCard(BuildContext context, BikeRoute route, int index, {hasDescription: true}) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);

    return ClipRRect(
      child: Container(
          width: 999,
          height: height * 0.15,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                        child: Container(
                            width: 999,
                            height: height * 0.15,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(circularRadius), bottomLeft: Radius.circular(circularRadius)),
                                image: new DecorationImage(
                                  image: Image.asset('assets/icons/route.png').image,
                                  fit: BoxFit.cover,
                                ))),
                        flex: 1)
                  ],
                ),
                flex: 3,
              ),
              Expanded(
                child: Padding(
                    child: Column(
                      children: [
                        Expanded(
                            child: Row(
                              children: [
                                Text('Traseul Mare', style: Theme.of(context).textTheme.bodyText1),
                              ],
                            ),
                            flex: 2),
                        Expanded(
                            child: Row(
                              children: [buildStars(context, 4, false)],
                            ),
                            flex: 2),
                        if (hasDescription)
                          Expanded(
                              child: Row(
                                children: [
                                  Text('Scris scris scris scris scris ', style: Theme.of(context).textTheme.bodyText2),
                                ],
                              ),
                              flex: 1),
                        SizedBox(
                          height: 2,
                        ),
                        Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Align(
                                      child: Image.asset('assets/icons/dt.png', width: 20, height: 24),
                                      alignment: Alignment.centerLeft,
                                    ),
                                    flex: 4),
                                Expanded(
                                  flex: 8,
                                  child: Align(
                                    child: Text('252 Km',
                                        style: TextStyle(
                                            fontSize: hasDescription ? 14.0 : 12.0,
                                            color: Theme.of(context).accentColor.withOpacity(0.75),
                                            fontWeight: FontWeight.bold)),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                                Expanded(
                                    child: Align(child: Image.asset('assets/icons/pin_tag.png', width: 20, height: 20), alignment: Alignment.center), flex: 4),
                                Expanded(child: Image.asset('assets/icons/church_tag.png', width: 20, height: 20), flex: 4),
                                Expanded(child: Image.asset('assets/icons/ruin_tag.png', width: 20, height: 20), flex: 4),
                                Spacer(
                                  flex: 1,
                                )
                              ],
                            ),
                            flex: 3)
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(15, 4, 0, 0)),
                flex: 4,
              )
            ],
          )),
    );
  }

  static Widget buildSmallRouteCard2(BuildContext context, BikeRoute route, int index, {hasDescription: true}) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);

    return ClipRRect(
      child: Container(
          width: 326,
          height: height * 0.15,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                        child: Container(
                            width: 999,
                            height: height * 0.15,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(circularRadius), bottomLeft: Radius.circular(circularRadius)),
                                image: new DecorationImage(
                                  image: Image.asset('assets/icons/route.png').image,
                                  fit: BoxFit.cover,
                                ))),
                        flex: 1)
                  ],
                ),
                flex: 3,
              ),
              Expanded(
                child: Padding(
                    child: Column(
                      children: [
                        Expanded(
                            child: Row(
                              children: [
                                Text('Traseul Mare', style: Theme.of(context).textTheme.bodyText1),
                              ],
                            ),
                            flex: 2),
                        Expanded(
                            child: Row(
                              children: [buildStars(context, 4, false)],
                            ),
                            flex: 2),
                        if (hasDescription)
                          Expanded(
                              child: Row(
                                children: [
                                  Text('Scris scris scris scris scris ', style: Theme.of(context).textTheme.bodyText2),
                                ],
                              ),
                              flex: 1),
                        SizedBox(
                          height: 2,
                        ),
                        Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Align(
                                      child: Image.asset('assets/icons/dt.png', width: 20, height: 24),
                                      alignment: Alignment.centerLeft,
                                    ),
                                    flex: 4),
                                Expanded(
                                  flex: 8,
                                  child: Align(
                                    child: Text('252 Km',
                                        style: TextStyle(
                                            fontSize: hasDescription ? 14.0 : 12.0,
                                            color: Theme.of(context).accentColor.withOpacity(0.75),
                                            fontWeight: FontWeight.bold)),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                                Expanded(
                                    child: Align(child: Image.asset('assets/icons/pin_tag.png', width: 20, height: 20), alignment: Alignment.center), flex: 4),
                                Expanded(child: Image.asset('assets/icons/church_tag.png', width: 20, height: 20), flex: 4),
                                Expanded(child: Image.asset('assets/icons/ruin_tag.png', width: 20, height: 20), flex: 4),
                                Spacer(
                                  flex: 1,
                                )
                              ],
                            ),
                            flex: 3)
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(15, 4, 0, 0)),
                flex: 4,
              )
            ],
          )),
    );
  }

  static Widget buildBigRouteCard(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);

    return ClipRRect(
      borderRadius: BorderRadius.circular(circularRadius),
      child: Container(
          width: width,
          height: height * 0.2,
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 36, blurRadius: 24, offset: Offset(0, 13))]),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                        child: Container(
                            width: 999,
                            height: height * 0.15,
                            decoration: BoxDecoration(
                                image: new DecorationImage(
                              image: Image.asset('assets/icons/route.png').image,
                              fit: BoxFit.cover,
                            ))),
                        flex: 1)
                  ],
                ),
                flex: 3,
              ),
              Expanded(
                child: Padding(
                    child: Column(
                      children: [
                        Expanded(
                            child: Row(
                              children: [
                                Text('Traseul Mare', style: Theme.of(context).textTheme.bodyText1),
                              ],
                            ),
                            flex: 2),
                        Expanded(
                            child: Row(
                              children: [buildStars(context, 4, false)],
                            ),
                            flex: 2),
                        Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: RichText(
                                      maxLines: 3,
                                      text: TextSpan(
                                        text: 'Scris scris scris cris scris scris scris Scris scris scris scris scris ',
                                        style: Theme.of(context).textTheme.bodyText2,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    flex: 1)
                              ],
                            ),
                            flex: 4),
                        SizedBox(
                          height: 2,
                        ),
                        Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Align(
                                      child: Image.asset('assets/icons/dt.png', width: 20, height: 24),
                                      alignment: Alignment.centerLeft,
                                    ),
                                    flex: 4),
                                Expanded(
                                  flex: 8,
                                  child: Align(
                                    child: Text('252 Km',
                                        style: TextStyle(fontSize: 14, color: Theme.of(context).accentColor.withOpacity(0.75), fontWeight: FontWeight.bold)),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                                Expanded(
                                    child: Align(child: Image.asset('assets/icons/pin_tag.png', width: 20, height: 20), alignment: Alignment.center), flex: 4),
                                Expanded(child: Image.asset('assets/icons/church_tag.png', width: 20, height: 20), flex: 4),
                                Expanded(child: Image.asset('assets/icons/ruin_tag.png', width: 20, height: 20), flex: 4),
                                Spacer(
                                  flex: 1,
                                )
                              ],
                            ),
                            flex: 3)
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(15, 4, 0, 4)),
                flex: 4,
              )
            ],
          )),
    );
  }

  //------------------------------------------------------------------------------------

  static Widget buildAnnouncementBanner(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 3, blurRadius: 5, offset: Offset(0, 3))]),
          height: 0.25 * height,
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
                        Spacer(flex: 1),
                        Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text(context.read<LanguageManager>().details),
                              ),
                            ))
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
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return Shimmer.fromColors(
        highlightColor: Colors.white,
        baseColor: Colors.black.withOpacity(0.01),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                color: Colors.white,
              ),
              height: 0.2 * height,
            )));
  }

  static Widget buildSmallObjectiveShimmerCard(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: InkWell(
            onTap: () {},
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 4))]),
                width: 0.35 * width,
                height: max(200, 0.275 * height),
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
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: InkWell(
            onTap: () {
              var objectiveInfo = new ObjectiveInfo(objective: objective, fromRoute: ModalRoute.of(context).settings.name);
              //Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo);
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                width: 0.35 * width,
                height: max(200, 0.275 * height),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                                child: ClipRRect(
                                  child: Image.asset(
                                    'assets/images/bisericalemn_000.jpg',
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
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
    double height = max(656, MediaQuery.of(context).size.height - 80);
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
              width: 0.35 * width,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(context.read<LanguageManager>().homeSeeAllSavedObjectives,
                              textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Theme.of(context).primaryColor))),
                    ),
                  )
                ],
              ),
            )));
  }

  static Widget buildSmallObjectiveCardC(BuildContext context, Objective objective) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: InkWell(
            onTap: () {
              var objectiveInfo = new ObjectiveInfo(objective: objective, fromRoute: ModalRoute.of(context).settings.name);
              //Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo);
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                width: 0.35 * width,
                height: 0.275 * height,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                                child: ClipRRect(
                                  child: Image.asset(
                                    'assets/images/bisericalemn_000.jpg',
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
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
    double height = max(656, MediaQuery.of(context).size.height - 80);
    var user = Provider.of<AuthenticatedUser>(context);
    return InkWell(
        onTap: () {},
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
            height: height * 0.35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: ClipRRect(
                      child: Image.asset('assets/images/bisericalemn_000.jpg', fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                                  child: OutlinedButton(
                                      onPressed: () async {
                                        Navigator.pushNamed(context, RoutesScreen.route, arguments: objective);
                                      },
                                      style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          textStyle: TextStyle(fontSize: 14),
                                          primary: Theme.of(context).hintColor,
                                          side: BorderSide(style: BorderStyle.solid, color: Theme.of(context).hintColor, width: 0),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
                                      child: Text(context.read<LanguageManager>().routes)))
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
                                child: ElevatedButton(
                                  onPressed: () {
                                    var objectiveInfo = new ObjectiveInfo(objective: objective, fromRoute: ModalRoute.of(context).settings.name);
                                    //  Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo);
                                  },
                                  child: Text(context.read<LanguageManager>().details),
                                  style: ElevatedButton.styleFrom(
                                      textStyle: TextStyle(fontSize: 14.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
                                ),
                              )
                            ])
                          ],
                        )),
                    flex: 1)
              ],
            )));
  }

  static buildNearestObjectiveButton(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: InkWell(
          child: Container(
              height: 64,
              width: 999,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
              child: Align(
                child: Text(
                  context.read<LanguageManager>().homeSeeAllObjectives,
                  style: TextStyle(fontSize: 20, color: Theme.of(context).hintColor),
                  textAlign: TextAlign.center,
                ),
                alignment: Alignment.center,
              )),
          onTap: () {
            context.read<MainBloc>().objectiveEventSync.add(Constants.NavigateToExplore);
          },
        ));
  }

  static buildShimmerRouteCard(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
            height: height * 0.3,
            child: Column(children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
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
                                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
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
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
            height: height * 0.3,
            child: Column(children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          Expanded(
                              flex: 20,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                        child: ClipRRect(
                                          child: Image.asset('assets/images/bisericalemn_000.jpg', fit: BoxFit.cover),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 12.0),
                                      ),
                                      flex: 1),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                        child: Container(
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
                                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
                                  ),
                                ],
                              )),
                          Expanded(
                              flex: 8,
                              child: Column(
                                children: [
                                  Container(
                                    child: buildRouteStats(context, route),
                                  )
                                ],
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
                        Text(route.distance.toStringAsFixed(0) + ' Km', style: Theme.of(context).textTheme.bodyText1)
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
                        Loader.show(context, progressIndicator: CircularProgressIndicator(color: Theme.of(context).primaryColor));
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
                          bikeRoute.userRating = serverRoute.userRating;
                        }

                        var db = await DatabaseService().database;

                        var pinnedRouteRow = await db.query('routepinnedcomment', where: 'route_id = ?', whereArgs: [bikeRoute.id]);
                        if (pinnedRouteRow.length > 0) {
                          bikeRoute.pinnedComment = RoutePinnedComment.fromMap(pinnedRouteRow.first);
                        }
                        Navigator.of(context).pushNamed(MapScreen.route, arguments: bikeRoute);
                        Loader.hide();
                      } on Exception catch (e) {
                        Loader.hide();
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
