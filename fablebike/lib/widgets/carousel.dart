import 'package:flutter/material.dart';
import '../models/route.dart';

class Carousel extends StatefulWidget {
  final Function(int) onItemChanged;
  final BikeRoute bikeRoute;
  final BuildContext context;

  Carousel({Key key, this.onItemChanged, this.context, this.bikeRoute}) : super(key: key);

  @override
  _Carousel createState() => _Carousel();
}

class _Carousel extends State<Carousel> {
  _Carousel({Key key});

  @override
  Widget build(BuildContext context) {
    return _buildCarousel(context, widget.onItemChanged, widget.bikeRoute);
  }
}

Widget _buildCarousel(BuildContext context, onItemChanged, BikeRoute bikeRoute) {
  Function(int) callBack = onItemChanged;

  List<Widget> carouselItems = [];

  for (var i = 0; i < bikeRoute.pois.length; i++) {
    carouselItems.add(_buildCarouselItem(context, bikeRoute.pois[i]));
  }

  return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    SizedBox(
        height: 96,
        child: PageView(controller: PageController(viewportFraction: 0.5), onPageChanged: (value) => {onItemChanged(value)}, children: carouselItems)),
  ]);
}

Widget _buildCarouselItem(BuildContext context, PointOfInterest poi) {
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
            children: [Text(poi.name)],
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'poi');
              },
              child: Text('Detalii'))
        ],
      ),
    ),
  );
}
