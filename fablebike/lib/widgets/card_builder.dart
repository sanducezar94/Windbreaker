import 'dart:math';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/objective.dart';
import 'package:fablebike/pages/sections/gradient_icon.dart';
import 'package:fablebike/services/navigator_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardBuilder {
  static double circularRadius = 12.0;
  static Widget buildProfileBar(BuildContext context, String tab, String subtitle) {
    final Shader linearGradient = LinearGradient(
      colors: <Color>[
        Theme.of(context).accentColor,
        Theme.of(context).primaryColorDark,
      ],
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
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
        Spacer(flex: 1)
      ],
    );
  }

  static Widget buildStars(BuildContext context, rating, applyShadow, {double opacity: 1, double size: 18}) {
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
            child: Align(
                child: Icon(
                  Icons.star,
                  color: rating > i ? Color.fromRGBO(255, 196, 107, 1).withOpacity(opacity) : Colors.grey.withOpacity(opacity),
                  size: size,
                ),
                alignment: Alignment.centerLeft))
    ]);
  }

  static Widget buildInteractiveStars(BuildContext context, rating, size, {Function callBack}) {
    return Row(children: [
      for (var i = 0; i < 5; i++)
        Padding(
            child: Container(
                child: InkWell(
              child: rating > i
                  ? GradientIcon(Icons.star, size)
                  : Icon(
                      Icons.star,
                      color: Colors.grey,
                      size: size,
                    ),
              onTap: () {
                callBack(i + 1);
              },
            )),
            padding: EdgeInsets.symmetric(horizontal: 10.0)),
    ]);
  }

  static Widget buildSmallObjectiveCarouselCard(BuildContext context, int index, Objective objective, bool noInfo) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);

    return Padding(
        padding: index == 0 ? EdgeInsets.fromLTRB(0, 6, 10.0, 6) : EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        child: InkWell(
            onTap: () {
              objective.userRating = 0;
              var objectiveInfo = new ObjectiveInfo(objective: objective, fromRoute: ModalRoute.of(context).settings.name);
              Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo);
            },
            child: Stack(
              children: [
                Container(
                  height: 999,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
                    image: new DecorationImage(
                      image: Image.asset('assets/images/objectives/' + objective.image).image,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                      boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.025), spreadRadius: 2, blurRadius: 6, offset: Offset(0, 0))]),
                  width: width,
                ),
                noInfo
                    ? Positioned(
                        bottom: 6,
                        left: 16,
                        child: Container(
                          width: 999,
                          height: 40,
                          child: Column(children: [
                            Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: RichText(
                                          maxLines: 2,
                                          text: TextSpan(text: objective.name, style: Theme.of(context).textTheme.headline3),
                                          textAlign: TextAlign.start,
                                        ),
                                        flex: 1)
                                  ],
                                ),
                                flex: 6),
                          ]),
                        ),
                      )
                    : Positioned(
                        child: Container(
                          width: 999,
                          height: height * 0.075,
                          child: Column(children: [
                            Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: RichText(
                                          maxLines: 2,
                                          text: TextSpan(text: objective.name, style: Theme.of(context).textTheme.headline3),
                                          textAlign: TextAlign.start,
                                        ),
                                        flex: 2)
                                  ],
                                ),
                                flex: 2),
                            if (!NavigatorHelper().isGuestUser(context))
                              Expanded(
                                  child: Row(
                                children: [
                                  buildStars(context, objective.rating, true),
                                  SizedBox(width: 5),
                                  Text(objective.rating.toStringAsFixed(1) + ' (' + objective.ratingCount.toString() + ')',
                                      style: TextStyle(fontSize: 12.0, color: Colors.white))
                                ],
                              ))
                          ]),
                        ),
                        bottom: 20,
                        left: 16)
              ],
            )));
  }

  static Widget buildlargeObjectiveCard(BuildContext context, Objective objective, {Function bookmarkCallback}) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
        child: Stack(
          children: [
            InkWell(
                child: Hero(
                    child: Container(
                      height: height * 0.25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
                          image: new DecorationImage(
                            image: Image.asset('assets/images/objectives/' + objective.image).image,
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 3))]),
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
                      boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.025), spreadRadius: 2, blurRadius: 6, offset: Offset(0, 0))]),
                  width: width,
                ),
                tag: 'obj-layer' + objective.name),
            Positioned(
                top: 16,
                right: 20,
                child: InkWell(
                  onTap: () => bookmarkCallback(objective.id),
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.45)),
                    width: 36,
                    height: 36,
                    child: Icon(objective.is_bookmarked ? Icons.bookmark : Icons.bookmark_outline, size: 20, color: Colors.white),
                  ),
                )),
            Positioned(
                child: Container(
                  width: 999,
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
                            Text(objective.name, style: Theme.of(context).textTheme.headline3),
                          ],
                        ),
                        flex: 6),
                    if (!NavigatorHelper().isGuestUser(context))
                      Expanded(
                          child: Row(
                            children: [
                              buildStars(context, objective.rating, true),
                              SizedBox(width: 5),
                              Text(objective.rating.toStringAsFixed(1) + ' (' + objective.ratingCount.toString() + ')',
                                  style: TextStyle(fontSize: 12.0, color: Colors.white))
                            ],
                          ),
                          flex: 4),
                  ]),
                ),
                bottom: 16,
                left: 20)
          ],
        ));
  }

  static Widget buildSmallRouteCard(BuildContext context, BikeRoute route, int index, {hasDescription: true}) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);

    return ClipRRect(
      child: Container(
          width: 999,
          height: height * 0.25,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                        child: Container(
                            width: 999,
                            height: height * 0.15,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(circularRadius), topRight: Radius.circular(circularRadius)),
                                image: new DecorationImage(
                                  image: Image.asset('assets/icons/route.png').image,
                                  fit: BoxFit.cover,
                                ))),
                        flex: 1)
                  ],
                ),
                flex: 4,
              ),
              Expanded(
                child: Padding(
                    child: Column(
                      children: [
                        Spacer(flex: 1),
                        Expanded(
                            child: Align(
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: RichText(
                                          maxLines: 2,
                                          text: TextSpan(text: route.name, style: Theme.of(context).textTheme.bodyText1),
                                          textAlign: TextAlign.start,
                                        ),
                                        flex: 2)
                                  ],
                                ),
                                alignment: Alignment.topCenter),
                            flex: 5),
                        if (!NavigatorHelper().isGuestUser(context))
                          Expanded(
                              child: Row(
                                children: [buildStars(context, route.rating, false)],
                              ),
                              flex: 2),
                        Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Align(
                                      child: Text(route.distance.toStringAsFixed(0) + ' Km',
                                          style: TextStyle(
                                              fontSize: hasDescription ? 14.0 : 12.0,
                                              color: Theme.of(context).accentColor.withOpacity(0.75),
                                              fontWeight: FontWeight.bold)),
                                      alignment: Alignment.center,
                                    ),
                                    flex: 6),
                                Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Image.asset('assets/icons/pin_tag.png', width: 20, height: 20),
                                        Image.asset('assets/icons/church_tag.png', width: 20, height: 20),
                                        Image.asset('assets/icons/ruin_tag.png', width: 20, height: 20),
                                      ],
                                    ),
                                    flex: 12),
                                Spacer(flex: 1)
                              ],
                            ),
                            flex: 4),
                        SizedBox(height: 4)
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(10, 4, 0, 0)),
                flex: 5,
              )
            ],
          )),
    );
  }

  static Widget buildBigRouteCard(BuildContext context, BikeRoute bikeRoute) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);

    return ClipRRect(
      borderRadius: BorderRadius.circular(circularRadius),
      child: Container(
          width: width,
          height: height * 0.225,
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
              boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.5), spreadRadius: 36, blurRadius: 24, offset: Offset(0, 13))]),
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
                        Spacer(flex: 2),
                        Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Align(
                                        child: RichText(
                                          maxLines: 2,
                                          text: TextSpan(
                                            text: bikeRoute.name,
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        alignment: Alignment.topLeft),
                                    flex: 1)
                              ],
                            ),
                            flex: NavigatorHelper().isGuestUser(context) ? 6 : 8),
                        SizedBox(
                          height: 2,
                        ),
                        if (!NavigatorHelper().isGuestUser(context))
                          Expanded(
                              child: Row(
                                children: [buildStars(context, bikeRoute.rating, false)],
                              ),
                              flex: 4),
                        Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: RichText(
                                      maxLines: 2,
                                      text: TextSpan(
                                        text: bikeRoute.description,
                                        style: Theme.of(context).textTheme.bodyText2,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    flex: 1)
                              ],
                            ),
                            flex: 8),
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
                                    child: Text(bikeRoute.distance.toStringAsFixed(0) + ' Km',
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
                            flex: 6)
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(14, 0, 15, 4)),
                flex: 4,
              )
            ],
          )),
    );
  }

  static Widget buildPreviewGallery(BuildContext context) {
    double smallDivider = 10.0;
    double bigDivider = 20.0;
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);

    return Column(children: [
      Row(children: [
        Text(
          "Poze",
          style: Theme.of(context).textTheme.headline2,
          textAlign: TextAlign.start,
        )
      ]),
      SizedBox(height: smallDivider),
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
                          decoration: BoxDecoration(
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))]),
                        ),
                        SizedBox(height: bigDivider),
                        Container(
                          child: ClipRRect(
                              child: Image.asset('assets/icons/route.png', width: width * 0.5, height: height * 0.35, fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(12.0)),
                          decoration: BoxDecoration(
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))]),
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
                          decoration: BoxDecoration(
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))]),
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
                                        gradient: LinearGradient(begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter, colors: [
                                          Colors.black.withOpacity(0.25),
                                          Colors.black.withOpacity(0.75),
                                        ], stops: [
                                          0,
                                          1
                                        ]),
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))]),
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
                          decoration: BoxDecoration(
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))]),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(8, 4, 0, 0)))
          ],
        ),
        width: 999,
        height: bigDivider * 1 + height * 0.65,
      )
    ]);
  }
}
