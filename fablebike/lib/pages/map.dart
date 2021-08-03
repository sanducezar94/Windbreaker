import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/comments.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/fullscreen_map.dart';
import 'package:fablebike/pages/sections/comments_section.dart';
import 'package:fablebike/services/route_service.dart';
import 'package:fablebike/widgets/carousel.dart';
import 'package:fablebike/widgets/rating_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/models/route.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:map_elevation/map_elevation.dart';
import 'package:provider/provider.dart';
import 'package:latlong/latlong.dart';
import 'package:share_plus/share_plus.dart';

LatLng myLocation = LatLng(46.45447, 27.72501);

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

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
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

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  int _stars = 0;

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    this.setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      this.setState(() {
        _connectionStatus = result;
      });
    });
  }

  void goToPoint(LatLng dest) {
    final latTween = Tween<double>(begin: mapController.center.latitude, end: dest.latitude);
    final longTween = Tween<double>(begin: mapController.center.longitude, end: dest.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: 10.0);

    var controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(LatLng(latTween.evaluate(animation), longTween.evaluate(animation)), zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  LatLng getcenter() {
    var l = widget.bikeRoute.rtsCoordinates.length;
    LatLng value = LatLng(0, 0);
    for (var i = 0; i < widget.bikeRoute.rtsCoordinates.length; i++) {
      value.latitude += widget.bikeRoute.rtsCoordinates[i].latitude / l;
      value.longitude += widget.bikeRoute.rtsCoordinates[i].longitude / l;
    }
    return value;
  }

  /* Future<double> getKmTraveled() async {
    double km = 0;
    for (var i = 0; i < widget.bikeRoute.rtsCoordinates.length - 1; i++) {
      var distanceToUser = mapMath.calculateDistance(
          widget.bikeRoute.rtsCoordinates[i].latitude, widget.bikeRoute.rtsCoordinates[i].longitude, myLocation.latitude, myLocation.longitude);

      if (distanceToUser > 2) {
        km += mapMath.calculateDistance(widget.bikeRoute.rtsCoordinates[i].latitude, widget.bikeRoute.rtsCoordinates[i].longitude,
            widget.bikeRoute.rtsCoordinates[i + 1].latitude, widget.bikeRoute.rtsCoordinates[i + 1].longitude);
      } else {
        i = 9999;
      }
    }
    kmTraveled = km;
    return km;
  } */

  Widget _buildStar(int starCount) {
    return InkWell(
      child: Icon(
        Icons.star,
        color: _stars >= starCount ? Theme.of(context).primaryColor : Colors.grey,
        size: 40,
      ),
      onTap: () async {
        _stars = starCount;
        var newRating = await RouteService().rateRoute(rating: starCount, route_id: widget.bikeRoute.id);
        setState(() {
          if (newRating != null && newRating != 0.0) {
            widget.bikeRoute.rating = newRating;
            widget.bikeRoute.ratingCount += 1;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: const Duration(milliseconds: 800),
                backgroundColor: Theme.of(context).primaryColor,
                content: Text('Votul a fost inregistrat cu succes!')));
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    var user = Provider.of<AuthenticatedUser>(context);

    if (widget.bikeRoute == null) {
      Navigator.of(context).pop();
      return Text('');
    }

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
    _buildMapStat(IconData iconData, String title, String value) {
      return Row(
        children: [
          Expanded(
              child: Icon(
                iconData,
                color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                size: 32,
              ),
              flex: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                )
              ],
            ),
            flex: 10,
          )
        ],
      );
    }

    _buildMap() {
      return Container(
          height: height * 1.45 - 80,
          child: Column(children: [
            Spacer(flex: 5),
            Expanded(
                child: ClipRRect(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
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
                                plugins: [LocationMarkerPlugin()]),
                            layers: [
                              TileLayerOptions(
                                tileProvider: AssetTileProvider(),
                                maxZoom: 10.0,
                                urlTemplate: 'assets/map/{z}/{x}/{y}.png',
                              ),
                              PolylineLayerOptions(
                                polylines: [
                                  Polyline(points: widget.bikeRoute.rtsCoordinates, strokeWidth: 8, color: Colors.blue),
                                ],
                              ),
                              LocationMarkerLayerOptions(),
                              MarkerLayerOptions(markers: markers),
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
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
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
                                  Navigator.of(context).pushNamed(FullScreenMap.route, arguments: widget.bikeRoute);
                                },
                              ))
                        ],
                      ),
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(16.0),
                    )),
                flex: 60),
            Spacer(
              flex: 5,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                child: Column(
                  children: [
                    Spacer(flex: 2),
                    Expanded(
                        child: Padding(
                          child: Column(
                            children: [
                              Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        widget.bikeRoute.name,
                                        style: Theme.of(context).textTheme.headline3,
                                      ),
                                    ],
                                  ),
                                  flex: 10),
                              Spacer(
                                flex: 4,
                              ),
                              Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.place,
                                        color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                                        size: 24,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        widget.bikeRoute.description,
                                        style: Theme.of(context).textTheme.headline4,
                                      ),
                                    ],
                                  ),
                                  flex: 10),
                              Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.directions,
                                        color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                                        size: 24,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '1.2km',
                                        style: Theme.of(context).textTheme.headline4,
                                      ),
                                    ],
                                  ),
                                  flex: 10)
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                        ),
                        flex: 20),
                    Spacer(flex: 5),
                    Expanded(
                        child: Padding(
                            child: Row(
                              children: [
                                Expanded(
                                    child: _buildMapStat(Icons.directions_bike_outlined, 'Distanta', widget.bikeRoute.distance.toStringAsFixed(0) + ' Km'),
                                    flex: 2),
                                Expanded(child: _buildMapStat(Icons.av_timer_outlined, 'Durata', '30 min'), flex: 2),
                                Expanded(child: _buildMapStat(Icons.landscape_outlined, 'Dificultate', 'Medie'), flex: 2),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 15.0)),
                        flex: 10),
                    Spacer(flex: 2),
                  ],
                ),
              ),
              flex: 45,
            ),
            Spacer(flex: 5),
            Expanded(
                child: Column(
                  children: [
                    Expanded(
                        child: Padding(
                          child: Column(
                            children: [
                              Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        'Obiective pe aceasta ruta',
                                        style: Theme.of(context).textTheme.bodyText1,
                                      ),
                                    ],
                                  ),
                                  flex: 10),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 00.0),
                        ),
                        flex: 4),
                    Expanded(
                        child: Container(
                            child: Carousel(
                                objectives: widget.bikeRoute.objectives,
                                context: context,
                                onItemChanged: (int index) {
                                  this.setState(() {
                                    this.currentPoint = index;
                                  });
                                  goToPoint(widget.bikeRoute.objectives[index].coords);
                                })),
                        flex: 20),
                    Spacer(flex: 1),
                  ],
                ),
                flex: 80),
            Expanded(
                child: Column(
                  children: [
                    Expanded(
                        child: Padding(
                          child: Column(
                            children: [
                              Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        'Evalueaza ruta',
                                        style: Theme.of(context).textTheme.bodyText1,
                                      ),
                                    ],
                                  ),
                                  flex: 10),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 00.0),
                        ),
                        flex: 4),
                    Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                child: Row(children: <Widget>[
                                  for (var i = 1; i <= 5; i++)
                                    Expanded(
                                      child: _buildStar(i),
                                    )
                                ]),
                                padding: EdgeInsets.symmetric(horizontal: 15.0),
                              ),
                              flex: 1,
                            )
                          ],
                        ),
                        flex: 10),
                    Spacer(flex: 1),
                  ],
                ),
                flex: 30),
            Expanded(
                child: Column(
                  children: [
                    Expanded(
                        child: Padding(
                          child: Column(
                            children: [
                              Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        'Despre ruta',
                                        style: Theme.of(context).textTheme.bodyText1,
                                      ),
                                    ],
                                  ),
                                  flex: 10),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 00.0),
                        ),
                        flex: 5),
                    Spacer(
                      flex: 2,
                    ),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(18.0)),
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                          child: Column(
                            children: [
                              Expanded(
                                child: _buildComment(
                                    context, Comment(userId: 0, id: 0, text: 'Am plecat 5 si neam intors 2', user: 'Pacea Poc', icon: ''), false, null),
                                flex: 1,
                              )
                            ],
                          ),
                        ),
                        flex: 12),
                    Spacer(flex: 2),
                    Expanded(
                      child: Row(children: [
                        Expanded(
                          flex: 1,
                          child: Align(
                              alignment: Alignment.center,
                              child: InkWell(
                                child: Text(
                                  'Vezi toate comentariile (' + widget.bikeRoute.commentCount.toString() + ')',
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
                                  textAlign: TextAlign.start,
                                ),
                                onTap: () {
                                  _buildBottomSheet(context, widget.bikeRoute);
                                },
                              )),
                        )
                      ]),
                      flex: 5,
                    ),
                  ],
                ),
                flex: 50),
            Spacer(flex: 5)
          ]));
    }

    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Row(
                children: [
                  Expanded(
                      child: Text(
                        'Inapoi',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      flex: 10),
                  Expanded(
                      child: InkWell(
                        onTap: () {
                          Share.share('check out my website https://example.com');
                        },
                        child: Icon(Icons.share, color: Theme.of(context).accentColor),
                      ),
                      flex: 1)
                ],
              ),
              centerTitle: true,
              iconTheme: IconThemeData(color: Theme.of(context).accentColor),
              shadowColor: Colors.white54,
              backgroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              child: Padding(
                child: _buildMap(),
                padding: EdgeInsets.symmetric(horizontal: 20.0),
              ),
            )));
  }
}

_buildBottomSheet(BuildContext context, BikeRoute bikeRoute) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      isDismissible: true,
      backgroundColor: Colors.white.withOpacity(0),
      builder: (context) {
        return CommentSection(canPost: true, route_id: bikeRoute.id, totalPages: bikeRoute.commentCount ~/ 5 + (bikeRoute.commentCount % 5 == 0 ? 0 : 1));
      });
}

_buildInfoBox(BuildContext context, Icon icon, title, label) {
  return FractionallySizedBox(
      heightFactor: 1,
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor, width: 2, style: BorderStyle.solid)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
          child: Column(
            children: [
              Spacer(
                flex: 4,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: icon,
                      flex: 1,
                    ),
                  ],
                ),
                flex: 10,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      flex: 1,
                    )
                  ],
                ),
                flex: 10,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      flex: 1,
                    )
                  ],
                ),
                flex: 10,
              ),
              Spacer(
                flex: 4,
              ),
            ],
          )));
}

Widget _buildComment(BuildContext context, Comment comment, bool moreButton, VoidCallback onTap) {
  var user = context.read<AuthenticatedUser>();

  if (moreButton) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Center(
            child: ElevatedButton(
          onPressed: onTap,
          child: Icon(Icons.add_circle_outline),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(12),
          ),
        )));
  } else {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: ListTile(
        minVerticalPadding: 10,
        horizontalTitleGap: 025,
        leading: !user.lowDataUsage
            ? FutureBuilder<Uint8List>(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(48.0),
                      child: snapshot.data == null
                          ? Image.asset('assets/icons/user.png', width: 48, height: 48)
                          : Image.memory(snapshot.data, width: 48, height: 48),
                    );
                  } else {
                    return Image.asset('assets/icons/user.png', width: 48, height: 48);
                  }
                },
                future: getIcon(imageName: comment.icon, username: comment.user, userId: comment.userId))
            : Image(image: AssetImage('assets/icons/user.png')),
        title: Text(
          comment.user,
          style: Theme.of(context).textTheme.headline5,
        ),
        subtitle: Text(
          comment.text,
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    );
  }
}
