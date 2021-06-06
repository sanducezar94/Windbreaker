import 'package:fablebike/models/route.dart';
import 'package:fablebike/widgets/carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong/latlong.dart';

import 'dart:math' show cos, sqrt, asin;

LatLng myLocation = LatLng(46.45447, 27.72501);

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

class MapSection extends StatefulWidget {
  const MapSection({
    Key key,
    @required this.bikeRoute,
  }) : super(key: key);

  final BikeRoute bikeRoute;

  @override
  _MapSectionState createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> with TickerProviderStateMixin {
  double rotation = 0;
  double size = 24.0;
  bool init = false;
  MapController mapController;
  double kmTraveled = 0;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  void goToPoint(LatLng dest) {
    final latTween =
        Tween<double>(begin: mapController.center.latitude, end: dest.latitude);
    final longTween = Tween<double>(
        begin: mapController.center.longitude, end: dest.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: 13.0);

    var controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));

    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(latTween.evaluate(animation), longTween.evaluate(animation)),
          zoomTween.evaluate(animation));
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

  Future<double> getKmTraveled() async {
    double km = 0;
    for (var i = 0; i < widget.bikeRoute.rtsCoordinates.length - 1; i++) {
      var distanceToUser = calculateDistance(
          widget.bikeRoute.rtsCoordinates[i].latitude,
          widget.bikeRoute.rtsCoordinates[i].longitude,
          myLocation.latitude,
          myLocation.longitude);

      if (distanceToUser > 2) {
        km += calculateDistance(
            widget.bikeRoute.rtsCoordinates[i].latitude,
            widget.bikeRoute.rtsCoordinates[i].longitude,
            widget.bikeRoute.rtsCoordinates[i + 1].latitude,
            widget.bikeRoute.rtsCoordinates[i + 1].longitude);
      } else {
        i = 9999;
      }
    }
    return km;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;

    var markers = <Marker>[];
    for (var i = 0; i < widget.bikeRoute.pois.length; i++) {
      markers.add(Marker(
          width: this.size,
          height: this.size,
          builder: (ctx) => Transform.rotate(
              angle: -this.rotation * 3.14159 / 180,
              child: Container(
                  child: Image(image: AssetImage('assets/icons/church.png')))),
          point: widget.bikeRoute.pois[i].coords));
    }

    return Column(children: [
      FutureBuilder<double>(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return Text(snapshot.data.toStringAsPrecision(3) + ' km');
              }
              return Text('Ai iesit de pe ruta.');
            } else
              return Text('Ai iesit de pe ruta.');
          },
          future: getKmTraveled()),
      Container(
        height: height * 0.35,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
              center: LatLng(46.6387, 27.7372),
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
            PolylineLayerOptions(
              polylines: [
                Polyline(
                    points: widget.bikeRoute.rtsCoordinates,
                    strokeWidth: 4,
                    color: Colors.blue),
              ],
            ),
            LocationMarkerLayerOptions(),
            MarkerLayerOptions(markers: markers),
          ],
        ),
      ),
      Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 16, right: 0, left: 0, bottom: 16),
          child: Carousel(
              bikeRoute: widget.bikeRoute,
              context: context,
              onItemChanged: (int index) {
                goToPoint(widget.bikeRoute.pois[index].coords);
              })),
    ]);
  }
}
