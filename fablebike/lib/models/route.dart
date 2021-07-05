import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:latlong/latlong.dart';
import 'package:map_elevation/map_elevation.dart';
import 'package:proj4dart/proj4dart.dart';

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
  List<Coordinates> coordinates;
  List<Objective> objectives;

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

class Coordinates {
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

  Coordinates.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'],
        elevation = json['elevation'];
}

class Objective {
  int id;
  double latitude;
  double longitude;
  String name;
  String description;
  String icon;
  String image;
  int routeId;
  LatLng coords;
  bool is_bookmarked;

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude, 'name': name, 'description': description, 'route_id': routeId};
  }

  Objective.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        id = json['id'],
        is_bookmarked = json['is_bookmarked'] == 1,
        longitude = json['longitude'],
        icon = json['icon'],
        image = json['image'],
        name = json['name'],
        description = json['description'],
        coords = LatLng(json['latitude'], json['longitude']);
}

class ObjectiveInfo {
  Objective objective;
  String fromRoute;

  ObjectiveInfo({
    this.objective,
    this.fromRoute,
  });
}
