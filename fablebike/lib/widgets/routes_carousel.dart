import 'package:fablebike/pages/route_map.dart';
import 'package:fablebike/widgets/physics.dart';
import 'package:fablebike/widgets/shimmer_card_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/route.dart';
import 'card_builder.dart';

class RouteCarousel extends StatefulWidget {
  final List<BikeRoute> routes;
  final BuildContext context;
  final double width;
  final bool isShimer;

  RouteCarousel({Key key, this.context, this.routes, this.width, this.isShimer: false}) : super(key: key);

  @override
  _RoteCarousel createState() => _RoteCarousel();
}

class _RoteCarousel extends State<RouteCarousel> {
  _RoteCarousel({Key key});

  @override
  Widget build(BuildContext context) {
    return widget.isShimer ? _buildShimmerCarousel(context, widget.width) : _buildCarousel(context, widget.routes, widget.width);
  }
}

Widget _buildShimmerCarousel(BuildContext context, double width) {
  List<Widget> carouselItems = [];
  for (var i = 0; i < 4; i++) {
    carouselItems.add(ShimmerCardBuilder.buildSmallRouteCard(context, i));
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
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))]),
                child: carouselItems[index],
                width: width,
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
