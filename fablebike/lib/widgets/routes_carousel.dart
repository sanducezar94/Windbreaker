import 'package:fablebike/pages/objective.dart';
import 'package:fablebike/pages/route_map.dart';
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
  for (var i = 0; i < routes.length; i++) {
    carouselItems.add(CardBuilder.buildSmallRouteCard(context, routes[i], i, hasDescription: false));
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
              child: InkWell(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))]),
                  child: carouselItems[index],
                  width: width,
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(RouteMapScreen.route, arguments: [routes[index]]);
                },
              ),
              padding: index == 0 ? EdgeInsets.fromLTRB(0, 4, 10, 4) : EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0)),
          physics: CustomScrollPhysics(itemDimension: width + 20),
          scrollDirection: Axis.horizontal,
          itemCount: carouselItems.length,
        )),
    Spacer(
      flex: 1,
    ),
  ]);
}
