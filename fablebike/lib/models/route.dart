import 'package:latlong/latlong.dart';
import 'package:map_elevation/map_elevation.dart';

class BikeRoute {
  int id;
  String name;
  String description;
  double rating;
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
        //descent = json['descent'],
        //ascent = json['ascent'],
        //difficulty = json['difficulty'],
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
  double latitude;
  double longitude;
  String name;
  String description;
  String icon;
  int routeId;
  LatLng coords;

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude, 'name': name, 'description': description, 'route_id': routeId};
  }

  PointOfInterest.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'],
        name = json['name'],
        description = json['description'],
        icon = json['photos'],
        coords = LatLng(json['latitude'], json['longitude']);
}
