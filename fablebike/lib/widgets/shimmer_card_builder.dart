import 'dart:math';

import 'package:fablebike/models/route.dart';
import 'package:fablebike/pages/objective.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCardBuilder {
  static double circularRadius = 16.0;
  static Widget buildSmallObjectiveCarouselCard(BuildContext context, int index) {
    double width = MediaQuery.of(context).size.width;
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
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(circularRadius)), color: Colors.black26),
                    width: width,
                  ),
                ),
              ],
            )));
  }

  static Widget buildlargeObjectiveCard(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
      child: Shimmer.fromColors(
        highlightColor: Colors.white,
        baseColor: Colors.black12,
        child: Container(
          width: width,
          height: height * 0.25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            color: Colors.black26,
          ),
        ),
      ),
    );
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
                        child: Shimmer.fromColors(
                          highlightColor: Colors.white,
                          baseColor: Colors.black12,
                          child: Container(
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
                flex: 3,
              ),
              Expanded(
                child: Padding(
                    child: Column(
                      children: [
                        Spacer(flex: 2),
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
                            flex: 8),
                        Spacer(flex: 2),
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
                            flex: 4),
                        Spacer(flex: 2),
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
                            flex: 8),
                        Spacer(flex: 2),
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
                            flex: 6)
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(14, 0, 15, 14)),
                flex: 4,
              )
            ],
          )),
    );
  }
}
