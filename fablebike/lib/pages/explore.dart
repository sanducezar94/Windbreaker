import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expandable/expandable.dart';
import 'package:fablebike/bloc/objective_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/objective.dart';
import 'package:fablebike/pages/routes.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/models/route.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:focus_widget/focus_widget.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

LatLng myLocation = LatLng(46.45447, 27.72501);

class ExploreScreen extends StatefulWidget {
  static String route = '/explore';
  ExploreScreen({Key key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
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
  bool _blocInitialized = false;
  double rotation = 0;
  double size = 36.0;
  bool init = false;
  double infoContainerHeight = 0;

  void goToPoint(LatLng dest) {
    final latTween = Tween<double>(begin: mapController.center.latitude, end: dest.latitude);
    final longTween = Tween<double>(begin: mapController.center.longitude, end: dest.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: 12.0);

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

  void expandAnimation(double end) {
    final topTween = Tween<double>(begin: top, end: end);

    var controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastLinearToSlowEaseIn);

    controller.addListener(() {
      setState(() {
        top = topTween.evaluate(animation);
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
          height: height + 64,
          child: Stack(
            fit: StackFit.loose,
            children: [
              StreamBuilder<List<Objective>>(
                builder: (BuildContext context, AsyncSnapshot<List<Objective>> snapshot) {
                  if (snapshot.hasData) {
                    List<Widget> children = [];
                    var filteredList = snapshot.data;

                    var markers = <Marker>[];
                    for (var i = 0; i < filteredList.length; i++) {
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
                                  expandAnimation(height * 0.645);
                                  setState(() {
                                    loadResults = true;
                                  });
                                },
                              ))),
                          point: filteredList[i].coords));
                    }

                    return FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                          center: myLocation,
                          minZoom: 10.0,
                          maxZoom: 13.0,
                          zoom: 10.0,
                          onTap: (dest) {
                            expandAnimation(height * 1.1);
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
                        PolylineLayerOptions(polylines: _polylines),
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
                  top: top,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: loadResults
                          ? Container(
                              height: height * 0.4,
                              child: SizedBox(width: 10),
                            )
                          : ObjectiveContainer(
                              objective: currentObjective,
                              closeModal: expandAnimation,
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
                                  expandAnimation(height * 1.1);
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
                                    hintStyle: TextStyle(color: Colors.grey),
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
                                  height: height * 0.35,
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
                                                  padding: EdgeInsets.all(0),
                                                  itemCount: list.length,
                                                  itemBuilder: (context, index) => ListTile(
                                                      leading: Icon(Icons.search),
                                                      title: InkWell(
                                                        child: Text(list[index].name),
                                                        onTap: () {
                                                          currentObjective = list[index];
                                                          expandAnimation(height * 0.65);
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
                  top: min(70, height * 0.075)),
            ],
          ),
        )));
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
    double height = max(656, MediaQuery.of(context).size.height - 80);
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
                                          widget.closeModal(2000.0);
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.objective.name,
                                        style: Theme.of(context).textTheme.headline5,
                                      ),
                                      RichText(
                                        maxLines: 3,
                                        text: TextSpan(
                                          text: widget.objective.name,
                                          style: Theme.of(context).textTheme.headline4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 3),
                                      child: Container(
                                          child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, RoutesScreen.route, arguments: widget.objective);
                                        },
                                        style: OutlinedButton.styleFrom(
                                            textStyle: TextStyle(fontSize: 14),
                                            primary: Theme.of(context).primaryColor,
                                            side: BorderSide(style: BorderStyle.solid, color: Theme.of(context).primaryColor, width: 1),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
                                        child: Text(context.read<LanguageManager>().routes),
                                      ))))
                            ]),
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
                                            //Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo);
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
