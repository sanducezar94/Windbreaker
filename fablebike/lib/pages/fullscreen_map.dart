import 'dart:async';
import 'dart:ffi';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expandable/expandable.dart';
import 'package:fablebike/bloc/objective_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/objective.dart';
import 'package:fablebike/pages/routes.dart';
import 'package:fablebike/pages/sections/comments_section.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/models/route.dart';
import 'package:focus_widget/focus_widget.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong/latlong.dart';
import 'package:map_elevation/map_elevation.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

LatLng myLocation = LatLng(46.45447, 27.72501);

class FullScreenMap extends StatefulWidget {
  static String route = '/route_map';
  final BikeRoute bikeRoute;
  FullScreenMap({Key key, this.bikeRoute}) : super(key: key);

  @override
  _FullScreenMapState createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> with TickerProviderStateMixin {
  final ScrollController listViewController = ScrollController();
  final _mapBlock = ObjectiveBloc();
  final _searchBlock = ObjectiveBloc();
  TextEditingController searchController = TextEditingController();
  MapController mapController = MapController();
  final Connectivity _connectivity = Connectivity();
  List<Polyline> _polylines = [];
  ExpandableController expandableController = ExpandableController();
  FocusNode _node = FocusNode();
  Objective currentObjective;
  bool loadResults = false;

  double top = 999;
  double iconBottom = 0;
  String _containerMode = 'poi';
  bool _blocInitialized = false;
  double rotation = 0;
  double size = 36.0;
  bool init = false;
  bool _showMarkers = true;
  double infoContainerHeight = 0;

  LatLng hoverPoint = LatLng(0, 0);

  void goToPoint(LatLng dest, {double zoom = 12.0}) {
    final latTween = Tween<double>(begin: mapController.center.latitude, end: dest.latitude);
    final longTween = Tween<double>(begin: mapController.center.longitude, end: dest.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: zoom);

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

  void expandAnimation(bool retract, double deviceHeight, {double containerSize = 0.35}) {
    final containerEnd = retract ? deviceHeight + 80.0 : deviceHeight * 0.65 + 80.0;
    final iconsEnd = retract ? 0.0 : deviceHeight * containerSize;
    final topTween = Tween<double>(begin: top, end: containerEnd);
    final iconBottomTween = Tween<double>(begin: iconBottom, end: iconsEnd);

    var controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastLinearToSlowEaseIn);

    controller.addListener(() {
      setState(() {
        top = topTween.evaluate(animation);
        iconBottom = iconBottomTween.evaluate(animation);
      });
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        this.loadResults = false;
        _searchBlock.objectiveEventSync
            .add(ObjectiveBlocEvent(eventType: ObjectiveEventType.ObjectiveSearchEvent, args: {'search_query': searchController.text}));
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

  getRoutes(Objective obj) async {
    var db = await DatabaseService().database;

    var objToRouteRows = await db.query('objectivetoroute', where: 'objective_id = ?', whereArgs: [obj.id]);

    var routeRows = await db.rawQuery('SELECT route_id FROM objectivetoroute WHERE objective_id = ${obj.id}');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    var user = Provider.of<AuthenticatedUser>(context);

    if (!_blocInitialized) {
      _mapBlock.objectiveEventSync.add(ObjectiveBlocEvent(eventType: ObjectiveEventType.ObjectiveInitializeEvent, args: {}));
      _searchBlock.objectiveEventSync.add(ObjectiveBlocEvent(eventType: ObjectiveEventType.ObjectiveInitializeEvent, args: {}));
      this._blocInitialized = true;
    }

    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
            body: Container(
          height: height + 80,
          child: Stack(
            fit: StackFit.loose,
            children: [
              StreamBuilder<List<Objective>>(
                builder: (BuildContext context, AsyncSnapshot<List<Objective>> snapshot) {
                  if (snapshot.hasData) {
                    List<Widget> children = [];
                    var filteredList = snapshot.data;

                    var markers = <Marker>[];
                    markers.add(Marker(width: this.size, height: this.size, point: hoverPoint, builder: (ctx) => Icon(Icons.arrow_circle_down)));

                    for (var i = 0; i < filteredList.length && this._showMarkers; i++) {
                      markers.add(Marker(
                          width: this.size,
                          height: this.size,
                          builder: (ctx) => Transform.rotate(
                              angle: -this.rotation * 3.14159 / 180,
                              child: Container(
                                  child: InkWell(
                                child: Image(image: AssetImage('assets/icons/' + filteredList[i].icon + '_pin.png')),
                                onTap: () {
                                  currentObjective = filteredList[i];
                                  getRoutes(filteredList[i]);
                                  goToPoint(LatLng(filteredList[i].latitude, filteredList[i].longitude));
                                  expandAnimation(false, height);
                                  setState(() {
                                    loadResults = true;
                                    this._containerMode = 'poi';
                                  });
                                },
                              ))),
                          point: LatLng(filteredList[i].coords.latitude + 0.00125, filteredList[i].coords.longitude)));
                    }

                    return FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                          center: widget.bikeRoute.center,
                          minZoom: 10.0,
                          maxZoom: 13.0,
                          zoom: 10.0,
                          onTap: (dest) {
                            expandAnimation(true, height);
                            FocusScope.of(context).requestFocus(new FocusNode());
                          },
                          onPositionChanged: (mapPosition, _) {
                            if (!init) return;
                            setState(() {
                              this.rotation = this.mapController.rotation;
                            });
                          },
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
                    );
                  } else {
                    return Text('Loading...');
                  }
                },
                initialData: [],
                stream: _mapBlock.output,
              ),
              Positioned(
                  bottom: 16 + iconBottom,
                  right: 16,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(128.0)),
                          color: Theme.of(context).primaryColor,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                      child: Column(
                        children: [
                          Expanded(
                            child: Icon(Icons.fullscreen_exit, color: Colors.white, size: 30),
                          )
                        ],
                      ),
                      width: 40,
                      height: 40,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  )),
              Positioned(
                  bottom: 16 + iconBottom,
                  left: 16,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(128.0)),
                          color: Theme.of(context).primaryColor,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                      child: Column(
                        children: [
                          Expanded(
                            child: Icon(Icons.landscape_outlined, color: Colors.white, size: 24),
                          )
                        ],
                      ),
                      width: 40,
                      height: 40,
                    ),
                    onTap: () {
                      goToPoint(widget.bikeRoute.center, zoom: 10);
                      expandAnimation(false, height, containerSize: 0.25);
                      setState(() {
                        this._containerMode = 'elev';
                      });
                    },
                  )),
              Positioned(
                  bottom: 60 + iconBottom,
                  left: 16,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(128.0)),
                          color: Theme.of(context).primaryColor,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                      child: Column(
                        children: [
                          Expanded(
                            child: Icon(Icons.comment, color: Colors.white, size: 24),
                          )
                        ],
                      ),
                      width: 40,
                      height: 40,
                    ),
                    onTap: () {
                      _buildBottomSheet(context, widget.bikeRoute);
                    },
                  )),
              Positioned(
                  bottom: 104 + iconBottom,
                  left: 16,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(128.0)),
                          color: this._showMarkers ? Colors.black54 : Theme.of(context).primaryColor,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                      child: Column(
                        children: [
                          Expanded(
                            child: Icon(Icons.place, color: Colors.white, size: 24),
                          )
                        ],
                      ),
                      width: 40,
                      height: 40,
                    ),
                    onTap: () {
                      setState(() {
                        this._showMarkers = !this._showMarkers;
                      });
                    },
                  )),
              Positioned(
                  bottom: 148 + iconBottom,
                  left: 16,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(128.0)),
                          color: Theme.of(context).primaryColor,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                      child: Column(
                        children: [
                          Expanded(
                            child: Icon(Icons.gps_fixed, color: Colors.white, size: 24),
                          )
                        ],
                      ),
                      width: 40,
                      height: 40,
                    ),
                    onTap: () {
                      goToPoint(widget.bikeRoute.center, zoom: 10);
                    },
                  )),
              Positioned(
                  top: top + (this._containerMode == 'poi' ? 0 : 0.1 * height),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: _containerMode == 'poi'
                          ? ObjectiveContainer(
                              objective: currentObjective,
                              closeModal: expandAnimation,
                            )
                          : ElevationContainer(
                              bikeRoute: widget.bikeRoute,
                              closeModal: expandAnimation,
                              updateHoverPoint: (ElevationPoint point) {
                                setState(() {
                                  this.hoverPoint = point;
                                });
                              },
                            ))),
              Positioned(
                  height: height * 0.5,
                  width: width,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          FocusWidget.builder(
                            context,
                            builder: (context, _node) => Material(
                              child: TextField(
                                focusNode: this._node,
                                onTap: () {
                                  setState(() {
                                    this._containerMode = 'poi';
                                  });
                                  expandAnimation(true, height);
                                },
                                onChanged: (value) {
                                  _searchBlock.objectiveEventSync.add(
                                      ObjectiveBlocEvent(eventType: ObjectiveEventType.ObjectiveSearchEvent, args: {'search_query': searchController.text}));
                                },
                                controller: searchController,
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 0.0),
                                    prefixIcon: Icon(Icons.search),
                                    border: this._node.hasFocus
                                        ? OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)))
                                        : OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(24.0))),
                                    hintText: context.read<LanguageManager>().searchObjective),
                              ),
                              borderRadius: !this._node.hasFocus
                                  ? const BorderRadius.all(const Radius.circular(24.0))
                                  : BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                              shadowColor: Colors.white10,
                              elevation: 10.0,
                            ),
                          ),
                          if (this._node.hasFocus)
                            ClipRRect(
                              child: Container(
                                  height: height * 0.4,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: StreamBuilder<List<Objective>>(
                                          builder: (BuildContext context, AsyncSnapshot<List<Objective>> snapshot) {
                                            if (snapshot.hasData && snapshot.data != null) {
                                              var list = snapshot.data;
                                              if (list.isEmpty) return ListView();

                                              return ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  itemCount: list.length,
                                                  itemBuilder: (context, index) => ListTile(
                                                      leading: Icon(Icons.search),
                                                      title: InkWell(
                                                        child: Text(list[index].name),
                                                        onTap: () {
                                                          currentObjective = list[index];
                                                          expandAnimation(false, height);
                                                          searchController.text = list[index].name;
                                                          goToPoint(list[index].coords);
                                                          FocusScope.of(context).requestFocus(new FocusNode());
                                                          setState(() {});
                                                        },
                                                      )));
                                            }
                                            return CircularProgressIndicator();
                                          },
                                          initialData: [],
                                          stream: _searchBlock.output,
                                        ),
                                        flex: 1,
                                      )
                                    ],
                                  )),
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
                            )
                        ],
                      )),
                  top: 70),
            ],
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

class ElevationContainer extends StatelessWidget {
  final BikeRoute bikeRoute;
  final Function closeModal;
  final Function updateHoverPoint;
  const ElevationContainer({Key key, this.bikeRoute, this.closeModal, this.updateHoverPoint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Container(
        width: width,
        height: height * 0.25,
        color: Colors.white,
        child: Padding(
          child: NotificationListener<ElevationHoverNotification>(
            onNotification: (ElevationHoverNotification notification) {
              updateHoverPoint(notification.position);
              return true;
            },
            child: Elevation(
              bikeRoute.elevationPoints,
              color: Theme.of(context).primaryColor,
              elevationGradientColors:
                  ElevationGradientColors(gt10: Color.fromRGBO(186, 150, 51, 1), gt20: Color.fromRGBO(234, 120, 85, 1), gt30: Color.fromRGBO(255, 61, 0, 1)),
            ),
          ),
          padding: EdgeInsets.all(24),
        ));
  }
}

class ObjectiveContainer extends StatefulWidget {
  final Objective objective;
  final Function closeModal;
  ObjectiveContainer({Key key, this.objective, this.closeModal}) : super(key: key);
  @override
  _ObjectiveContainerState createState() => _ObjectiveContainerState();
}

class _ObjectiveContainerState extends State<ObjectiveContainer> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Container(
      width: width,
      height: height * 0.35,
      color: Colors.white,
      child: widget.objective == null
          ? Text("")
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: ClipRRect(
                          child: Stack(
                            children: [
                              ImageSlideshow(
                                width: double.infinity,
                                height: 200,
                                indicatorColor: Theme.of(context).primaryColor,
                                indicatorBackgroundColor: Colors.white,
                                initialPage: 0,
                                children: [
                                  Image.asset('assets/images/podu_001.jpg', fit: BoxFit.cover),
                                  Image.asset('assets/images/podu_002.jpg', fit: BoxFit.cover),
                                ],
                                onPageChanged: (value) {},
                                autoPlayInterval: 3000,
                              ),
                              Positioned(
                                  top: -8,
                                  right: -8,
                                  child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: InkWell(
                                        child: Icon(
                                          Icons.close,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        onTap: () {
                                          widget.closeModal(true, height);
                                        },
                                      ))),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        )),
                    flex: 1),
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                        child: Column(
                          children: [
                            Row(children: [
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    widget.objective.description,
                                    style: Theme.of(context).textTheme.bodyText2,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 3),
                                      child: Container(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            var objectiveInfo = new ObjectiveInfo(objective: widget.objective, fromRoute: ModalRoute.of(context).settings.name);
                                            Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo);
                                          },
                                          child: Text(context.read<LanguageManager>().details),
                                          style: ElevatedButton.styleFrom(
                                              textStyle: TextStyle(fontSize: 14.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
                                        ),
                                      )))
                            ])
                          ],
                        )),
                    flex: 1)
              ],
            ),
    );
  }
}
