import 'package:flutter/material.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/services/route_service.dart';
import 'package:fablebike/pages/sections/comments_section.dart';
import 'package:fablebike/pages/sections/map_section.dart';
import '../widgets/carousel.dart';
import '../widgets/rating_dialog.dart';

class MapScreen extends StatelessWidget {
  static const route = '/map';

  final BikeRoute bikeRoute;

  const MapScreen({
    Key key,
    @required this.bikeRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MapWidget(bikeRoute: bikeRoute);
  }
}

class MapWidget extends StatefulWidget {
  const MapWidget({
    Key key,
    @required this.bikeRoute,
  }) : super(key: key);

  final BikeRoute bikeRoute;

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final ScrollController listViewController = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;

    if (widget.bikeRoute == null) {
      Navigator.of(context).pop();
    }
    if (widget.bikeRoute != null)
      return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(title: Text(widget.bikeRoute.name)),
          body: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Column(
                  children: [
                    MapSection(bikeRoute: widget.bikeRoute),
                    Container(
                        height: 0.5 * height,
                        child: ListView(
                            controller: this.listViewController,
                            scrollDirection: Axis.vertical,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(widget.bikeRoute.rating
                                          .toStringAsPrecision(3)),
                                      Icon(Icons.star, color: Colors.orange),
                                      Text('(' +
                                          widget.bikeRoute.ratingCount
                                              .toString() +
                                          ')'),
                                      !isLoading
                                          ? ElevatedButton(
                                              onPressed: () async {
                                                var rating = await showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        RatingDialog());
                                                if (rating != null) {
                                                  this.setState(() {
                                                    this.isLoading = true;
                                                  });
                                                  var newRating =
                                                      await RouteService()
                                                          .rateRoute(
                                                              rating: rating,
                                                              route_id: widget
                                                                  .bikeRoute
                                                                  .id);
                                                  this.setState(() {
                                                    if (newRating > 0.0) {
                                                      widget.bikeRoute.rating =
                                                          newRating;
                                                      widget.bikeRoute
                                                          .ratingCount += 1;
                                                    }
                                                    this.isLoading = false;
                                                  });
                                                }
                                              },
                                              child: Text('Rate'))
                                          : CircularProgressIndicator()
                                    ],
                                  ),
                                ],
                              ),
                              CommentSection(route_id: widget.bikeRoute.id),
                            ])),
                  ],
                ),
              ],
            ),
          ));
  }
}
