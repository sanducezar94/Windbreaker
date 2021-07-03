import 'package:fablebike/pages/objective.dart';
import 'package:flutter/material.dart';
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

  for (var i = 0; i < objectives.length; i++) {
    carouselItems.add(CardBuilder.buildSmallObjectiveCard(context, objectives[i]));
  }

  return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    SizedBox(
        height: 0.275 * height,
        child: PageView(
            controller: PageController(viewportFraction: 0.35),
            onPageChanged: onItemChanged != null
                ? (value) {
                    onItemChanged(value);
                  }
                : null,
            children: carouselItems)),
  ]);
}

Widget _buildCarouselItem(BuildContext context, Objective objective, Function() onPageClosed) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.0),
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      child: Column(
        children: [
          Row(
            children: [Text(objective.name)],
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, ObjectiveScreen.route, arguments: objective).then((value) {
                  onPageClosed();
                });
              },
              child: Text('Detalii'))
        ],
      ),
    ),
  );
}
