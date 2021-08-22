import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/comments.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/route_map_header_delegate.dart';
import 'package:fablebike/widgets/card_builders.dart';
import 'package:fablebike/widgets/carousel.dart';
import 'package:fablebike/widgets/routes_carousel.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:fablebike/pages/sections/comments_section.dart';

class RouteMapScreen extends StatefulWidget {
  static const route = '/map';
  final BikeRoute bikeRoute;
  RouteMapScreen({Key key, @required this.bikeRoute}) : super(key: key);

  @override
  _RouteMapScreenState createState() => _RouteMapScreenState();
}

LatLng myLocation = LatLng(46.45447, 27.72501);

class _RouteMapScreenState extends State<RouteMapScreen> {
  final ScrollController listViewController = ScrollController();
  bool isLoading = false;
  String currentRoute = "poi";
  double rotation = 0;
  double size = 12.0;
  bool init = false;
  int currentPoint = 0;
  MapController mapController = MapController();
  double kmTraveled = 0;
  var hoverPoint = LatLng(0, 0);
  var currentTab = 'poi';
  LatLng center = LatLng(0, 0);

  int _stars = 0;

  List<Objective> objectives = [];

  @override
  Duration get transitionDuration => const Duration(milliseconds: 3000);

  @override
  Widget build(BuildContext context) {
    objectives.add(new Objective(id: 1, name: 'Test', description: 'Test'));
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    var user = Provider.of<AuthenticatedUser>(context);
    double smallDivider = 10.0;
    double bigDivider = 20.0;

    var markers = <Marker>[];
    markers.add(Marker(
        width: 64,
        height: 64,
        builder: (ctx) =>
            Transform.rotate(angle: -this.rotation * 3.14159 / 180, child: Container(child: Image(image: AssetImage('assets/icons/ruin_ppin.png')))),
        point: hoverPoint));
    for (var i = 0; i < widget.bikeRoute.objectives.length; i++) {
      markers.add(Marker(
          width: i == currentPoint ? 40 : 32,
          height: i == currentPoint ? 40 : 32,
          builder: (ctx) => Transform.rotate(
              angle: -this.rotation * 3.14159 / 180,
              child: Container(child: Image(image: AssetImage('assets/icons/' + widget.bikeRoute.objectives[i].icon + '_pin.png')))),
          point: widget.bikeRoute.objectives[i].coords));
    }

    return ColorfulSafeArea(
      overflowRules: OverflowRules.all(true),
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              height: 2000,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverPersistentHeader(
                    delegate: RouteHeader(64, 450, widget.bikeRoute),
                    pinned: false,
                    floating: true,
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Stack(
                        children: [
                          Positioned(
                              child: Opacity(
                                child: Container(
                                  width: width,
                                  height: bigDivider * 5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(0.0), bottomRight: Radius.circular(0.0)),
                                    image: new DecorationImage(
                                      image: Image.asset('assets/icons/bg_2.png').image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                opacity: 0.4,
                              ),
                              top: 0),
                          Positioned(
                              child: Opacity(
                                child: Container(
                                  width: width * 1.2,
                                  height: bigDivider * 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(0.0), bottomRight: Radius.circular(0.0)),
                                    image: new DecorationImage(
                                      image: Image.asset('assets/icons/bg_finish.png').image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                opacity: 0.4,
                              ),
                              bottom: 0,
                              left: -20),
                          Padding(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: bigDivider,
                                  ),
                                  Row(children: [
                                    Text(
                                      "Descriere",
                                      style: Theme.of(context).textTheme.headline2,
                                      textAlign: TextAlign.start,
                                    )
                                  ]),
                                  SizedBox(
                                    height: bigDivider,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: TextSpan(
                                          text:
                                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequa',
                                          style: Theme.of(context).textTheme.subtitle2),
                                      maxLines: 15,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  SizedBox(height: bigDivider),
                                  Row(children: [
                                    Text(
                                      "Harta",
                                      style: Theme.of(context).textTheme.headline2,
                                      textAlign: TextAlign.start,
                                    )
                                  ]),
                                  SizedBox(height: smallDivider),
                                  ClipRRect(
                                      child: Container(
                                        width: width,
                                        height: height * 0.25,
                                        decoration: BoxDecoration(color: Colors.white, boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 12, blurRadius: 16, offset: Offset(0, 3))
                                        ]),
                                        child: Stack(
                                          children: [
                                            FlutterMap(
                                              mapController: this.mapController,
                                              options: MapOptions(
                                                  center: widget.bikeRoute.center,
                                                  minZoom: 10.0,
                                                  maxZoom: 10.0,
                                                  zoom: 10.0,
                                                  swPanBoundary: LatLng(46.2318, 27.3077),
                                                  nePanBoundary: LatLng(46.9708, 28.1942),
                                                  plugins: []),
                                              layers: [
                                                TileLayerOptions(
                                                  tileProvider: AssetTileProvider(),
                                                  maxZoom: 10.0,
                                                  urlTemplate: 'assets/map/{z}/{x}/{y}.png',
                                                ),
                                                /* PolylineLayerOptions(
                                                  polylines: [
                                                    Polyline(points: widget.bikeRoute.rtsCoordinates, strokeWidth: 8, color: Colors.blue),
                                                  ],
                                                ),*/
                                                //LocationMarkerLayerOptions(),
                                                // MarkerLayerOptions(markers: markers),
                                              ],
                                            ),
                                            Positioned(
                                                bottom: 16,
                                                right: 16,
                                                child: InkWell(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.all(Radius.circular(128.0)),
                                                        color: Theme.of(context).primaryColor,
                                                        border: Border.all(color: Colors.white, width: 1),
                                                        boxShadow: [
                                                          BoxShadow(color: Colors.black.withOpacity(0.15), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))
                                                        ]),
                                                    child: Column(
                                                      children: [
                                                        Expanded(
                                                          child: Icon(Icons.fullscreen, color: Colors.white),
                                                        )
                                                      ],
                                                    ),
                                                    width: 32,
                                                    height: 32,
                                                  ),
                                                  onTap: () {
                                                    // Navigator.of(context).pushNamed(FullScreenMap.route, arguments: widget.bikeRoute);
                                                  },
                                                ))
                                          ],
                                        ),
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(16.0),
                                      )),
                                  SizedBox(height: bigDivider),
                                  Row(children: [
                                    Text(
                                      "Obiective de pe traseu",
                                      style: Theme.of(context).textTheme.headline2,
                                      textAlign: TextAlign.start,
                                    )
                                  ]),
                                  SizedBox(height: smallDivider),
                                  Container(
                                    child: Carousel(
                                      context: context,
                                      objectives: objectives,
                                      width: width * 0.55,
                                    ),
                                    height: height * 0.3,
                                    width: 999,
                                  ),
                                  SizedBox(
                                    height: bigDivider,
                                  ),
                                  Row(children: [
                                    Text(
                                      "Poze",
                                      style: Theme.of(context).textTheme.headline2,
                                      textAlign: TextAlign.start,
                                    )
                                  ]),
                                  SizedBox(height: bigDivider),
                                  Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      child: ClipRRect(
                                                          child: Image.asset('assets/icons/route.png',
                                                              width: width * 0.5, height: height * 0.175, fit: BoxFit.cover),
                                                          borderRadius: BorderRadius.circular(12.0)),
                                                      decoration: BoxDecoration(boxShadow: [
                                                        BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))
                                                      ]),
                                                    ),
                                                    SizedBox(height: bigDivider),
                                                    Container(
                                                      child: ClipRRect(
                                                          child: Image.asset('assets/icons/route.png',
                                                              width: width * 0.5, height: height * 0.35, fit: BoxFit.cover),
                                                          borderRadius: BorderRadius.circular(12.0)),
                                                      decoration: BoxDecoration(boxShadow: [
                                                        BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))
                                                      ]),
                                                    ),
                                                  ],
                                                ),
                                                padding: EdgeInsets.fromLTRB(0, 4, 16, 0))),
                                        Expanded(
                                            child: Padding(
                                                child: Column(
                                                  children: [
                                                    SizedBox(height: bigDivider * 2),
                                                    Container(
                                                      child: ClipRRect(
                                                          child: Image.asset('assets/icons/route.png',
                                                              width: width * 0.5, height: height * 0.35, fit: BoxFit.cover),
                                                          borderRadius: BorderRadius.circular(12.0)),
                                                      decoration: BoxDecoration(boxShadow: [
                                                        BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))
                                                      ]),
                                                    ),
                                                    SizedBox(height: bigDivider),
                                                    Container(
                                                      child: ClipRRect(
                                                          child: Stack(
                                                            children: [
                                                              Image.asset('assets/icons/route.png',
                                                                  width: width * 0.5, height: height * 0.175, fit: BoxFit.cover),
                                                              Container(
                                                                height: height * 0.175,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                                                    color: Colors.white,
                                                                    gradient: LinearGradient(
                                                                        begin: FractionalOffset.topCenter,
                                                                        end: FractionalOffset.bottomCenter,
                                                                        colors: [
                                                                          Colors.black.withOpacity(0.25),
                                                                          Colors.black.withOpacity(0.75),
                                                                        ],
                                                                        stops: [
                                                                          0,
                                                                          1
                                                                        ]),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Colors.black.withOpacity(0.025),
                                                                          spreadRadius: 2,
                                                                          blurRadius: 6,
                                                                          offset: Offset(0, 0))
                                                                    ]),
                                                                width: width,
                                                              ),
                                                              Container(
                                                                height: height * 0.175,
                                                                width: width * 0.5,
                                                                child: Align(
                                                                  alignment: Alignment.center,
                                                                  child: Text(
                                                                    '+6 Poze',
                                                                    style: Theme.of(context).textTheme.headline3,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          borderRadius: BorderRadius.circular(12.0)),
                                                      decoration: BoxDecoration(boxShadow: [
                                                        BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 6, blurRadius: 12, offset: Offset(0, 0))
                                                      ]),
                                                    ),
                                                  ],
                                                ),
                                                padding: EdgeInsets.fromLTRB(16, 4, 0, 0)))
                                      ],
                                    ),
                                    width: 999,
                                    height: bigDivider * 1 + height * 0.65,
                                  ),
                                  Row(children: [
                                    Text(
                                      context.read<LanguageManager>().routeEvaluate,
                                      style: Theme.of(context).textTheme.headline2,
                                      textAlign: TextAlign.start,
                                    )
                                  ]),
                                  SizedBox(height: smallDivider),
                                  Container(child: CardBuilder.buildInteractiveStars(context, 4, 48.0)),
                                  SizedBox(height: bigDivider),
                                  Row(children: [
                                    Text(
                                      "Despre ruta",
                                      style: Theme.of(context).textTheme.headline2,
                                      textAlign: TextAlign.start,
                                    )
                                  ]),
                                  SizedBox(height: bigDivider),
                                  //if (widget.bikeRoute.pinnedComment != null)
                                  Container(
                                    height: 80,
                                    width: 999,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                        color: Colors.white,
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 4, blurRadius: 8, offset: Offset(0, 3))]),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: _buildComment(
                                              context,
                                              Comment(
                                                  userId: 0,
                                                  id: 0,
                                                  text:
                                                      'Scris scris scris scris scris scris scris scris scris scris scris scris scris scris scris scris', // widget.bikeRoute.pinnedComment.comment,
                                                  user: 'User', //widget.bikeRoute.pinnedComment.username,
                                                  icon: ''),
                                              false,
                                              null),
                                          flex: 1,
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: bigDivider),
                                  //if (widget.bikeRoute.pinnedComment != null)
                                  Container(
                                    height: 80,
                                    width: 999,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                        color: Colors.white,
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 4, blurRadius: 8, offset: Offset(0, 3))]),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: _buildComment(
                                              context,
                                              Comment(
                                                  userId: 0,
                                                  id: 0,
                                                  text:
                                                      'Scris scris scris scris scris scris scris scris scris scris scris scris scris scris scris scris', // widget.bikeRoute.pinnedComment.comment,
                                                  user: 'User', //widget.bikeRoute.pinnedComment.username,
                                                  icon: ''),
                                              false,
                                              null),
                                          flex: 1,
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: bigDivider * 5),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0))
                        ],
                      )
                    ]),
                  )
                ],
              ))),
    );
  }
}

Widget _buildComment(BuildContext context, Comment comment, bool moreButton, VoidCallback onTap) {
  var user = context.read<AuthenticatedUser>();
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    child: ListTile(
      minVerticalPadding: 10,
      horizontalTitleGap: 15,
      leading: !user.lowDataUsage
          ? FutureBuilder<Uint8List>(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: snapshot.data == null
                        ? Image.asset('assets/icons/user.png', width: 80, height: 80)
                        : Image.memory(snapshot.data, width: 80, height: 80),
                  );
                } else {
                  return Image.asset('assets/icons/user.png', width: 80, height: 80);
                }
              },
              future: getIcon(imageName: comment.icon, username: comment.user, userId: comment.userId))
          : Image(image: AssetImage('assets/icons/user.png')),
      title: Text(
        comment.user,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      subtitle: Text(
        comment.text,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    ),
  );
}
