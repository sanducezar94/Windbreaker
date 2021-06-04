import 'package:latlong/latlong.dart';

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

  List<LatLng> coords;
  List<PointOfInterest> pois;

  BikeRoute(this.id, this.name, this.description, this.rating, this.ascent,
      this.descent, this.difficulty, this.coords);

  BikeRoute.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        rating = json["rating"] == null ? 0.0 : json["rating"],
        descent = json['descent'],
        ascent = json['ascent'],
        difficulty = json['difficulty'],
        file = json['file'],
        ratingCount = json["rating_count"],
        coords = getCoordsFromJson(json['coords']),
        pois = getPoisFromJson(json['pois']);
}

List<LatLng> getCoordsFromJson(jsonCoords) {
  if (jsonCoords == null) return [];
  List<LatLng> coordsList = [];
  for (var i = 0; i < jsonCoords.length; i++) {
    coordsList.add(LatLng(jsonCoords[i][0], jsonCoords[i][1]));
  }
  return coordsList;
}

List<PointOfInterest> getPoisFromJson(jsonPOI) {
  if (jsonPOI == null) return [];
  List<PointOfInterest> poiList = [];
  for (var i = 0; i < jsonPOI.length; i++) {
    poiList.add(PointOfInterest.fromJson(jsonPOI[i]));
  }
  return poiList;
}

class Coords {
  double latitude;
  double longitude;

  Coords.fromJson(List<dynamic> json)
      : latitude = json[0],
        longitude = json[1];
}

class PointOfInterest {
  double latitude;
  double longitude;
  String name;
  String description;
  String icon;
  LatLng coords;

  PointOfInterest.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'],
        name = json['name'],
        description = json['description'],
        icon = json['photos'],
        coords = LatLng(json['latitude'], json['longitude']);
}
