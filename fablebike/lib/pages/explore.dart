import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fablebike/bloc/poi_bloc.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/pages/sections/map_section.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fablebike/services/math_service.dart' as mapMath;
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatefulWidget {
  static String route = '/explore';
  ExploreScreen({Key key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  final ScrollController listViewController = ScrollController();
  final _bloc = ObjectiveBloc();
  bool _blocInitialized = false;
  double rotation = 0;
  double size = 12.0;
  bool init = false;
  MapController mapController;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    var user = Provider.of<AuthenticatedUser>(context);

    if (!this._blocInitialized) {
      _bloc.bookmarkEventSync.add(ObjectiveBlocEvent(eventType: ObjectiveEventType.ObjectiveInitializeEvent, args: {}));
      this._blocInitialized = true;
    }

    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          bottomNavigationBar: buildBottomBar(context, ExploreScreen.route),
          body: Container(
              height: height,
              child: StreamBuilder(
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    List<Widget> children = [];
                    var filteredList = snapshot.data;

                    return FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                          center: myLocation,
                          minZoom: 10.0,
                          maxZoom: 13.0,
                          zoom: 10.0,
                          onPositionChanged: (mapPosition, _) {
                            if (this.mapController.ready && !init) {
                              init = true;
                              return;
                            }
                            if (!init) return;
                            setState(() {
                              this.rotation = this.mapController.rotation;
                              if (this.mapController.zoom > 12.5) {
                                this.size = 64;
                              } else if (this.mapController.zoom > 11.5) {
                                this.size = 64;
                              } else {
                                this.size = 24;
                              }
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
                        LocationMarkerLayerOptions(),
                        MarkerLayerOptions(markers: []),
                      ],
                    );
                  } else {
                    return Text('Loading...');
                  }
                },
                initialData: [],
                stream: _bloc.output,
              )),
        ));
  }
}
