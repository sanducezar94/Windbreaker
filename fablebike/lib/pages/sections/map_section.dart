import 'package:fablebike/models/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong/latlong.dart';

class MapSection extends StatefulWidget {
  const MapSection({
    Key key,
    @required this.bikeRoute,
  }) : super(key: key);

  final BikeRoute bikeRoute;

  @override
  _MapSectionState createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  double rotation = 0;
  double size = 24.0;
  bool init = false;
  MapController mapController = new MapController();

  @override
  void initState() {
    super.initState();
    mapController = MapController();
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
      Container(
        height: height * 0.5,
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
            LocationMarkerLayerOptions(),
            PolylineLayerOptions(
              polylines: [
                Polyline(
                    points: widget.bikeRoute.coords,
                    strokeWidth: 4,
                    color: Colors.blue),
              ],
            ),
            MarkerLayerOptions(markers: markers),
          ],
        ),
      ),
    ]);
  }
}
