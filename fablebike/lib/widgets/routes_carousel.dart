import 'package:fablebike/pages/objective.dart';
import 'package:fablebike/widgets/physics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/route.dart';
import 'card_builders.dart';

class RouteCarousel extends StatefulWidget {
  final List<BikeRoute> routes;
  final BuildContext context;
  final double width;

  RouteCarousel({Key key, this.context, this.routes, this.width}) : super(key: key);

  @override
  _RoteCarousel createState() => _RoteCarousel();
}

class _RoteCarousel extends State<RouteCarousel> {
  _RoteCarousel({Key key});

  @override
  Widget build(BuildContext context) {
    return _buildCarousel(context, widget.routes, widget.width);
  }
}

Widget _buildCarousel(BuildContext context, List<BikeRoute> routes, double width) {
  List<Widget> carouselItems = [];
  final List<int> pages = List.generate(4, (index) => index);
  for (var i = 0; i < 7; i++) {
    carouselItems.add(CardBuilder.buildSmallRouteCard2(context, null, i, hasDescription: false));
  }

  return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    Spacer(
      flex: 1,
    ),
    Expanded(
        flex: 6,
        child: ListView.builder(
          clipBehavior: Clip.none,
          itemBuilder: (context, index) => Padding(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 3, blurRadius: 12, offset: Offset(0, 0))]),
                child: carouselItems[index],
                width: width,
              ),
              padding: index == 0 ? EdgeInsets.fromLTRB(0, 4, 10, 4) : EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0)),
          physics: CustomScrollPhysics(itemDimension: width + 20),
          scrollDirection: Axis.horizontal,
          itemCount: 7,
        )),
    Spacer(
      flex: 1,
    ),
  ]);
}
