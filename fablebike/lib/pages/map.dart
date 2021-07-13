import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/sections/comments_section.dart';
import 'package:fablebike/services/route_service.dart';
import 'package:fablebike/widgets/carousel.dart';
import 'package:fablebike/widgets/rating_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/models/route.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:map_elevation/map_elevation.dart';
import 'package:provider/provider.dart';
import 'package:latlong/latlong.dart';

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
  MapController mapController;
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
    final zoomTween = Tween<double>(begin: mapController.zoom, end: 13.0);

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
        width: 36,
        height: 36,
        builder: (ctx) =>
            Transform.rotate(angle: -this.rotation * 3.14159 / 180, child: Container(child: Image(image: AssetImage('assets/icons/ruin_ppin.png')))),
        point: hoverPoint));
    for (var i = 0; i < widget.bikeRoute.objectives.length; i++) {
      markers.add(Marker(
          width: 24,
          height: 24,
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
            bottomSheet: GestureDetector(
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
                  height: height * 0.025,
                  width: width,
                  child: Center(
                    child: Container(
                      width: width / 2,
                      height: height * 0.01,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
                    ),
                  )),
              onVerticalDragEnd: (v) {
                _buildBottomSheet(context, widget.bikeRoute);
              },
            ),
            appBar: AppBar(
              title: Row(
                children: [
                  Expanded(
                      child: Text(
                        widget.bikeRoute.name,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      flex: 10),
                  Expanded(
                      child: InkWell(
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
                child: Column(children: [
              Container(
                  height: height - 80,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(children: [
                        Spacer(
                          flex: 1,
                        ),
                        Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(18.0)),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
                              child: ClipRRect(
                                child: Stack(
                                  children: [
                                    FlutterMap(
                                      mapController: mapController,
                                      options: MapOptions(
                                          center: widget.bikeRoute.center,
                                          minZoom: 10.0,
                                          maxZoom: 13.0,
                                          zoom: 10.0,
                                          swPanBoundary: LatLng(46.2318, 27.3077),
                                          nePanBoundary: LatLng(46.9708, 28.1942),
                                          plugins: [LocationMarkerPlugin()]),
                                      layers: [
                                        TileLayerOptions(
                                          tileProvider: AssetTileProvider(),
                                          maxZoom: 13.0,
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
                                        left: 15,
                                        bottom: 15,
                                        child: Container(
                                          height: height * 0.065,
                                          width: width * 0.275,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(18.0)),
                                                          color: Colors.white70,
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 1, offset: Offset(0, 6))
                                                          ]),
                                                      child: Center(
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.star),
                                                            SizedBox(
                                                              width: 3,
                                                            ),
                                                            Text(
                                                                widget.bikeRoute.rating.toStringAsPrecision(2) +
                                                                    ' (' +
                                                                    widget.bikeRoute.ratingCount.toString() +
                                                                    ')',
                                                                style: Theme.of(context).textTheme.headline5),
                                                          ],
                                                        ),
                                                      )),
                                                  onTap: () async {
                                                    var rating = await showDialog(context: context, builder: (_) => RatingDialog());
                                                    var newRating = await RouteService().rateRoute(rating: rating, route_id: widget.bikeRoute.id);
                                                    setState(() {
                                                      if (newRating != null && newRating != 0.0) widget.bikeRoute.rating = newRating;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    Positioned(
                                        child: Container(
                                            height: height * 0.065,
                                            width: width * 0.275,
                                            child: Column(children: [
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                                                        color: Colors.white70,
                                                        boxShadow: [
                                                          BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 1, offset: Offset(0, 6))
                                                        ]),
                                                    child: Center(
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Image(image: AssetImage('assets/icons/dt.png'), height: 32),
                                                          SizedBox(
                                                            width: 3,
                                                          ),
                                                          Text(widget.bikeRoute.distance.toStringAsPrecision(3) + ' KM',
                                                              style: Theme.of(context).textTheme.headline5),
                                                        ],
                                                      ),
                                                    )),
                                              ),
                                            ])),
                                        bottom: 15,
                                        right: 15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                            flex: 15),
                        Spacer(
                          flex: 1,
                        ),
                        Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: OutlinedButton(
                                            onPressed: () async {
                                              setState(() {
                                                currentTab = 'poi';
                                              });
                                            },
                                            child: Text(
                                              context.read<LanguageManager>().routeObjectiveTab,
                                              style: TextStyle(color: currentTab != 'poi' ? Theme.of(context).primaryColor : Colors.white),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                                backgroundColor: currentTab == 'poi' ? Theme.of(context).primaryColor : Colors.white,
                                                textStyle: TextStyle(fontSize: 14.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), bottomLeft: Radius.circular(16.0)))),
                                          ),
                                          flex: 1),
                                      Expanded(
                                          child: OutlinedButton(
                                            onPressed: () async {
                                              setState(() {
                                                currentTab = 'elev';
                                              });
                                            },
                                            child: Text(context.read<LanguageManager>().routeElevationTab,
                                                style: TextStyle(color: currentTab != 'elev' ? Theme.of(context).primaryColor : Colors.white)),
                                            style: OutlinedButton.styleFrom(
                                                backgroundColor: currentTab == 'elev' ? Theme.of(context).primaryColor : Colors.white,
                                                textStyle: TextStyle(fontSize: 14.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(topRight: Radius.circular(16.0), bottomRight: Radius.circular(16.0)))),
                                          ),
                                          flex: 1),
                                    ],
                                  ),
                                )
                              ],
                            )),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(children: [
                                  currentTab == 'poi' ? Icon(Icons.place) : Icon(Icons.equalizer_rounded),
                                  SizedBox(width: 5),
                                  Text(
                                    currentTab == 'poi' ? context.read<LanguageManager>().routeObjectiveOn : context.read<LanguageManager>().routeElevation,
                                    style: Theme.of(context).textTheme.headline5,
                                    textAlign: TextAlign.start,
                                  )
                                ]),
                                flex: 2,
                              ),
                              Expanded(
                                flex: 10,
                                child: currentTab == 'poi'
                                    ? Container(
                                        child: Carousel(
                                            objectives: widget.bikeRoute.objectives,
                                            context: context,
                                            onItemChanged: (int index) {
                                              goToPoint(widget.bikeRoute.objectives[index].coords);
                                            }))
                                    : Container(
                                        child: ClipRRect(
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(18.0)),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(color: Colors.black.withOpacity(0.5), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))
                                                    ]),
                                                child: Padding(
                                                  child: NotificationListener<ElevationHoverNotification>(
                                                    onNotification: (ElevationHoverNotification notification) {
                                                      setState(() {
                                                        hoverPoint = notification.position;
                                                      });
                                                      return true;
                                                    },
                                                    child: Elevation(
                                                      widget.bikeRoute.elevationPoints,
                                                      color: Theme.of(context).primaryColor,
                                                      elevationGradientColors: ElevationGradientColors(
                                                          gt10: Color.fromRGBO(186, 150, 51, 1),
                                                          gt20: Color.fromRGBO(234, 120, 85, 1),
                                                          gt30: Color.fromRGBO(255, 61, 0, 1)),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.all(24),
                                                )),
                                            borderRadius: BorderRadius.circular(20.0)),
                                      ),
                              )
                            ],
                          ),
                          flex: 12,
                        )
                      ]))),
              SizedBox(
                height: 20,
              ),
              Container(
                  height: height,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(children: [
                              Icon(Icons.info),
                              SizedBox(width: 5),
                              Text(
                                context.read<LanguageManager>().routeInformation,
                                style: Theme.of(context).textTheme.headline5,
                                textAlign: TextAlign.start,
                              )
                            ]),
                            flex: 1,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoBox(
                                                context, Icon(Icons.pedal_bike_outlined), 'Distanta', widget.bikeRoute.distance.toString() + ' KM'),
                                            flex: 10,
                                          ),
                                          Spacer(
                                            flex: 2,
                                          ),
                                          Expanded(
                                            child:
                                                _buildInfoBox(context, Icon(Icons.place_outlined), 'Obiective', widget.bikeRoute.objectives.length.toString()),
                                            flex: 10,
                                          ),
                                        ],
                                      ),
                                      flex: 10,
                                    ),
                                    Spacer(
                                      flex: 2,
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoBox(context, Icon(Icons.landscape_outlined), 'Elevatie max.', '843 m'),
                                            flex: 10,
                                          ),
                                          Spacer(
                                            flex: 2,
                                          ),
                                          Expanded(
                                            child: _buildInfoBox(context, Icon(Icons.av_timer_outlined), 'Durata', 'Aprox. 20 min'),
                                            flex: 10,
                                          ),
                                        ],
                                      ),
                                      flex: 10,
                                    ),
                                  ],
                                )),
                            flex: 8,
                          ),
                          Spacer(flex: 1),
                          Expanded(
                            child: Row(children: [
                              Icon(Icons.star),
                              SizedBox(width: 5),
                              Text(
                                context.read<LanguageManager>().routeRating,
                                style: Theme.of(context).textTheme.headline5,
                                textAlign: TextAlign.start,
                              )
                            ]),
                            flex: 1,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [_buildStar(1), _buildStar(2), _buildStar(3), _buildStar(4), _buildStar(5)],
                            ),
                            flex: 2,
                          ),
                          Spacer(flex: 1),
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
                            flex: 1,
                          ),
                          Expanded(
                            child: Row(children: [
                              Expanded(
                                flex: 1,
                                child: Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      child: Text('Start', style: TextStyle(fontSize: 20)),
                                      style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(48),
                                      ),
                                    )),
                              )
                            ]),
                            flex: 8,
                          ),
                          Spacer(
                            flex: 1,
                          )
                        ],
                      ))),
            ]))));
  }
}

_buildBottomSheet(BuildContext context, BikeRoute bikeRoute) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
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
