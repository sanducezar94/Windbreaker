import 'dart:math';

import 'package:fablebike/models/route.dart';
import 'package:fablebike/pages/objective.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCardBuilder {
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
                  "Bine ai venit!", //subtitle,
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
              child: Icon(
                Icons.star,
                color: rating > i ? Theme.of(context).primaryColor : Colors.grey,
                size: size,
              ),
              onTap: () {
                callBack(i + 1);
              },
            )),
            padding: EdgeInsets.symmetric(horizontal: 10.0)),
    ]);
  }

  static Widget buildSmallObjectiveCarouselCard(BuildContext context, int index) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return Padding(
        padding: index == 0 ? EdgeInsets.fromLTRB(0, 6, 10.0, 6) : EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        child: InkWell(
            onTap: () {},
            child: Stack(
              children: [
                Shimmer.fromColors(
                  highlightColor: Colors.white,
                  baseColor: Colors.black12,
                  child: Container(
                    height: 999,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(circularRadius)),
                      image: new DecorationImage(
                        image: Image.asset('assets/images/bisericalemn_000.jpg').image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: width,
                  ),
                ),
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
                              boxShadow: [
                                BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 3))
                              ]),
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
                          boxShadow: [
                            BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.025), spreadRadius: 2, blurRadius: 6, offset: Offset(0, 0))
                          ]),
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
                                    buildStars(context, objective.rating, true),
                                    SizedBox(width: 5),
                                    Text(objective.rating.toStringAsFixed(1) + ' (' + objective.ratingCount.toString() + ')',
                                        style: TextStyle(fontSize: 12.0, color: Colors.white))
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

  static Widget buildSmallRouteCard(BuildContext context, int index) {
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
                        child: Shimmer.fromColors(
                          highlightColor: Colors.white,
                          baseColor: Colors.black12,
                          child: Container(
                            width: width,
                            height: height * 0.15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              color: Colors.black26,
                            ),
                          ),
                        ),
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
                            child: Shimmer.fromColors(
                              highlightColor: Colors.white,
                              baseColor: Colors.black12,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  color: Colors.black26,
                                ),
                              ),
                            ),
                            flex: 3),
                        Spacer(flex: 1),
                        Expanded(
                            child: Shimmer.fromColors(
                              highlightColor: Colors.white,
                              baseColor: Colors.black12,
                              child: Container(
                                height: height * 0.1,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  color: Colors.black26,
                                ),
                              ),
                            ),
                            flex: 2),
                        Spacer(flex: 1),
                        Expanded(
                            child: Shimmer.fromColors(
                              highlightColor: Colors.white,
                              baseColor: Colors.black12,
                              child: Container(
                                height: height * 0.1,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  color: Colors.black26,
                                ),
                              ),
                            ),
                            flex: 3),
                        Spacer(flex: 1),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(10, 4, 10, 4)),
                flex: 5,
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
                            flex: 8),
                        SizedBox(
                          height: 2,
                        ),
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
}
