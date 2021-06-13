import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:map_elevation/map_elevation.dart';

class BikeRoute {
  int id;
  String name;
  String description;
  double rating;
  double distance;
  double ascent;
  double descent;
  double difficulty;
  int ratingCount;
  String file;

  List<LatLng> rtsCoordinates;
  List<ElevationPoint> elevationPoints;
  List<Coords> coordinates;
  List<PointOfInterest> pois;

  BikeRoute(this.id, this.name, this.description, this.rating, this.ascent, this.descent, this.difficulty, this.rtsCoordinates);

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description, 'rating': rating, 'ratingCount': ratingCount};
  }

  BikeRoute.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        rating = json["rating"] == null ? 0.0 : json["rating"],
        distance = json["distance"],
        //descent = json['descent'],
        //ascent = json['ascent'],
        difficulty = 0.0,
        ratingCount = json["rating_count"];
}

class Coords {
  double latitude;
  double longitude;
  double elevation;
  int routeId;

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  ElevationPoint toElevationPoint() {
    return ElevationPoint(latitude, longitude, elevation);
  }

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude, 'elevation': elevation, 'route_id': routeId};
  }

  Coords.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'],
        elevation = json['elevation'];
}

class PointOfInterest {
  int id;
  double latitude;
  double longitude;
  String name;
  String description;
  String icon;
  int routeId;
  LatLng coords;
  bool is_bookmarked;

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude, 'name': name, 'description': description, 'route_id': routeId};
  }

  PointOfInterest.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        id = json['id'],
        is_bookmarked = json['is_bookmarked'] == 1,
        longitude = json['longitude'],
        name = json['name'],
        description = json['description'],
        icon = json['photos'],
        coords = LatLng(json['latitude'], json['longitude']);
}

class RouteFilter {
  RangeValues distance;
  RangeValues rating;
  RangeValues difficulty;
  RangeValues poiCount;

  RouteFilter() {
    distance = RangeValues(0.0, 500.0);
    rating = RangeValues(0.0, 5.0);
    difficulty = RangeValues(0.0, 5.0);
    poiCount = RangeValues(0.0, 30.0);
  }
}
