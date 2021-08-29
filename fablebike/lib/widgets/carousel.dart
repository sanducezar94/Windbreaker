import 'package:fablebike/pages/objective.dart';
import 'package:fablebike/widgets/physics.dart';
import 'package:fablebike/widgets/shimmer_card_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/route.dart';
import 'card_builder.dart';

class Carousel extends StatefulWidget {
  final List<Objective> objectives;
  final BuildContext context;
  final bool isShimmer;
  final double width;

  Carousel({Key key, this.context, this.objectives, this.width, this.isShimmer: false}) : super(key: key);

  @override
  _Carousel createState() => _Carousel();
}

class _Carousel extends State<Carousel> {
  _Carousel({Key key});

  @override
  Widget build(BuildContext context) {
    return !widget.isShimmer ? _buildCarousel(context, widget.objectives, widget.width) : _buildShimmerCarousel(context, widget.width);
  }
}

Widget _buildCarousel(BuildContext context, List<Objective> objectives, double width) {
  List<Widget> carouselItems = [];
  double deviceWidth = MediaQuery.of(context).size.height - 80;

  bool noInfo = width <= deviceWidth * 0.35;
  for (var i = 0; i < objectives.length; i++) {
    carouselItems.add(CardBuilder.buildSmallObjectiveCarouselCard(context, i, objectives[i], noInfo));
  }

  return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    Expanded(
        flex: 1,
        child: ListView.builder(
          clipBehavior: Clip.none,
          padding: EdgeInsets.all(0),
          itemBuilder: (context, index) => Container(
            child: carouselItems[index],
            width: width,
            decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), spreadRadius: 6, blurRadius: 9, offset: Offset(0, 3))]),
          ),
          physics: CustomScrollPhysics(itemDimension: width),
          scrollDirection: Axis.horizontal,
          itemCount: objectives.length,
        ))
  ]);
}

Widget _buildShimmerCarousel(BuildContext context, double width) {
  List<Widget> carouselItems = [];
  double height = MediaQuery.of(context).size.height - 80;
  double devideWidth = MediaQuery.of(context).size.height - 80;

  for (var i = 0; i < 4; i++) {
    carouselItems.add(ShimmerCardBuilder.buildSmallObjectiveCarouselCard(context, i));
  }

  return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    Expanded(
        flex: 1,
        child: ListView.builder(
          clipBehavior: Clip.none,
          padding: EdgeInsets.all(0),
          itemBuilder: (context, index) => Container(
            child: carouselItems[index],
            width: width,
            decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), spreadRadius: 6, blurRadius: 9, offset: Offset(0, 3))]),
          ),
          physics: CustomScrollPhysics(itemDimension: width),
          scrollDirection: Axis.horizontal,
          itemCount: 4,
        ))
  ]);
}
