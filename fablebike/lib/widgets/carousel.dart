import 'package:flutter/material.dart';

import '../models/route.dart';

class Carousel extends StatefulWidget {
  final Function(int) onItemChanged;
  final BuildContext context;

  Carousel({Key key, this.onItemChanged, this.context}) : super(key: key);

  @override
  _Carousel createState() => _Carousel();
}

class _Carousel extends State<Carousel> {
  _Carousel({Key key});

  @override
  Widget build(BuildContext context) {
    return _buildCarousel(context, widget.onItemChanged);
  }
}

Widget _buildCarousel(BuildContext context, onItemChanged) {
  Function(int) callBack = onItemChanged;

  return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    SizedBox(
        height: 156,
        child: PageView(
          controller: PageController(viewportFraction: 0.8),
          onPageChanged: (value) => {onItemChanged(value)},
          children: [
            _buildCarouselItem(context),
            _buildCarouselItem(context),
            _buildCarouselItem(context),
            _buildCarouselItem(context),
            _buildCarouselItem(context),
          ],
        )),
  ]);
}

Widget _buildCarouselItem(
  BuildContext context,
) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.0),
    child: Container(
      decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
    ),
  );
}
