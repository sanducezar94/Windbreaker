import 'package:fablebike/pages/objective.dart';
import 'package:fablebike/widgets/physics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/route.dart';
import 'card_builders.dart';

class Carousel extends StatefulWidget {
  final Function(int) onItemChanged;
  final Function() onPageClosed;
  final List<Objective> objectives;
  final BuildContext context;

  Carousel({Key key, this.onItemChanged, this.onPageClosed, this.context, this.objectives}) : super(key: key);

  @override
  _Carousel createState() => _Carousel();
}

class _Carousel extends State<Carousel> {
  _Carousel({Key key});

  @override
  Widget build(BuildContext context) {
    return _buildCarousel(context, widget.onItemChanged, widget.onPageClosed, widget.objectives);
  }
}

Widget _buildCarousel(BuildContext context, Function(int) onItemChanged, Function() onPageClosed, List<Objective> objectives) {
  List<Widget> carouselItems = [];
  double height = MediaQuery.of(context).size.height - 80;
  double width = MediaQuery.of(context).size.width - 80;

  for (var i = 0; i < objectives.length; i++) {
    carouselItems.add(CardBuilder.buildSmallObjectiveCarouselCard(context, objectives[i]));
  }

  return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    Expanded(
        flex: 1,
        child: PageView(
          children: carouselItems,
          pageSnapping: true,
          onPageChanged: onItemChanged,
          scrollDirection: Axis.horizontal,
          controller: PageController(viewportFraction: 0.8),
        ))
  ]);
}
