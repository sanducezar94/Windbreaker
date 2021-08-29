import 'dart:convert';
import 'dart:math';

import 'package:fablebike/models/comments.dart';
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
  int commentCount;
  int userRating;
  String file;
  RoutePinnedComment pinnedComment;

  LatLng center;
  List<LatLng> rtsCoordinates;
  List<ElevationPoint> elevationPoints;
  List<Coordinates> coordinates;
  List<Objective> objectives;

  BikeRoute(this.id, this.name, this.description, this.rating, this.ascent, this.descent, this.difficulty, this.rtsCoordinates);

  @override
  int compareTo(BikeRoute other) {
    if (this.rating == null || other == null) return null;

    if (this.rating > other.rating) return -1;
    if (this.rating < other.rating) return 1;
    if (this.rating == other.rating) return 0;
    return null;
  }

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
        center = json['center_lat'] != null ? LatLng(json['center_lat'], json['center_lng']) : LatLng(0, 0),
        commentCount = json["commentCount"],
        ratingCount = json["rating_count"],
        userRating = json["user_rating"];
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

  double rating;
  int ratingCount;
  int userRating;

  Objective({this.id, this.name, this.description});

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'description': description,
      'route_id': routeId,
      'rating': rating,
      'rating_count': ratingCount,
      'user_rating': userRating
    };
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
        coords = json['latitude'] == null || json['longitude'] == null ? LatLng(0.0, 0.0) : LatLng(json['latitude'], json['longitude']),
        rating = json['rating'],
        ratingCount = json['rating_count'],
        userRating = json['user_rating'];
}

class ObjectiveInfo {
  Objective objective;
  String fromRoute;

  ObjectiveInfo({
    this.objective,
    this.fromRoute,
  });
}
