import 'package:fablebike/models/route.dart';
import 'package:fablebike/widgets/card_builders.dart';
import 'package:flutter/cupertino.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/sliver_persistent_header.dart';

class ObjectiveHeader implements SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  final Objective objective;

  ObjectiveHeader(this.minExtent, this.maxExtent, this.objective);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    double smallDivider = 10.0;
    double bigDivider = 20.0;
    return Stack(
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
              tag: 'objective-hero' + objective.name),
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
            tag: 'obj-layer' + objective.name),
        Positioned(
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0))),
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
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(max(0, titleOpacity(shrinkOffset) - 0.75))),
                width: 48,
                height: 48,
                child: Icon(Icons.arrow_back, color: Colors.white.withOpacity(titleOpacity(shrinkOffset))),
              ),
              onTap: () => Navigator.pop(context),
            )),
        Positioned(
            top: 84,
            right: 20,
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(max(0, titleOpacity(shrinkOffset) - 0.75))),
                width: 48,
                height: 48,
                child: Icon(Icons.share, color: Colors.white.withOpacity(titleOpacity(shrinkOffset))),
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
                            Icon(Icons.cottage, color: Colors.white.withOpacity(titleOpacity(shrinkOffset))),
                          ],
                        ),
                        flex: 6),
                    Expanded(
                        child: Row(
                          children: [
                            Text('Biserica de lemn',
                                style: TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Nunito',
                                    color: Colors.white.withOpacity(titleOpacity(shrinkOffset)))),
                          ],
                        ),
                        flex: 8),
                    Expanded(
                        child: Row(
                          children: [
                            CardBuilder.buildStars(context, 3, true, opacity: titleOpacity(shrinkOffset)),
                            SizedBox(width: 5),
                            Text('4.5 (10)', style: TextStyle(fontSize: 12.0, color: Colors.white.withOpacity(titleOpacity(shrinkOffset))))
                          ],
                        ),
                        flex: 4),
                  ]),
                ),
                tag: 'obj-desc' + objective.name),
            bottom: 32,
            left: 20),
      ],
    );
  }

  double titleOpacity(double shrinkOffset) {
    return 1.0 - max(0.0, shrinkOffset + 0.2) / maxExtent;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration => null;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  TickerProvider get vsync => null;
}
