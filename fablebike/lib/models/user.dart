import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class RatingInfo {
  int objectId;
  double rating;
  int ratingCount;

  RatingInfo(this.objectId, this.rating, this.ratingCount);

  RatingInfo.empty() {}

  Map<String, dynamic> toMap() {
    return {
      'objectId': objectId,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }

  factory RatingInfo.fromMap(Map<String, dynamic> map) {
    return RatingInfo(
      map['id'] ?? 0,
      map['rating'] ?? 0.0,
      map['rating_count'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory RatingInfo.fromJson(String source) => RatingInfo.fromMap(json.decode(source));
}

class AuthenticatedUser {
  int id;
  String username;
  String email;
  String token;
  String icon;
  String roleTokens;

  bool lowDataUsage;
  bool isRomanianLanguage;

  List<RatingInfo> objectives;
  List<RatingInfo> routes;

  double distanceTravelled;
  int finishedRoutes;
  int objectivesVisited;

  AuthenticatedUser.emptyUser() {
    username = 'none';
    email = 'none';
    id = -1;
  }

  AuthenticatedUser.newUser(
    this.id,
    this.username,
    this.email,
  ) {
    distanceTravelled = 0;
    finishedRoutes = 0;
    objectivesVisited = 0;
    lowDataUsage = false;
    isRomanianLanguage = true;
  }

  AuthenticatedUser({
    this.id,
    this.username,
    this.email,
    this.token,
    this.icon,
    this.roleTokens,
    this.lowDataUsage,
    this.isRomanianLanguage,
    this.objectives,
    this.routes,
    this.distanceTravelled,
    this.finishedRoutes,
    this.objectivesVisited,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'token': token,
      'icon': icon,
      'roleTokens': roleTokens,
      'lowDataUsage': lowDataUsage,
      'isRomanianLanguage': isRomanianLanguage,
      'objectives': objectives?.map((x) => x.toMap())?.toList(),
      'routes': routes?.map((x) => x.toMap())?.toList(),
      'distanceTravelled': distanceTravelled,
      'finishedRoutes': finishedRoutes,
      'objectivesVisited': objectivesVisited,
    };
  }

  factory AuthenticatedUser.fromMap(Map<String, dynamic> map) {
    return AuthenticatedUser(
      id: map['id'] ?? 0,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
      icon: map['icon'] ?? '',
      roleTokens: map['roleTokens'] ?? '',
      lowDataUsage: map['lowDataUsage'] ?? false,
      isRomanianLanguage: map['isRomanianLanguage'] ?? false,
      objectives: List<RatingInfo>.from(map['login_data']['objectives']?.map((x) => RatingInfo.fromMap(x) ?? RatingInfo.empty()) ?? const []),
      routes: List<RatingInfo>.from(map['login_data']['routes']?.map((x) => RatingInfo.fromMap(x) ?? RatingInfo.empty()) ?? const []),
      distanceTravelled: map['distanceTravelled'] ?? 0.0,
      finishedRoutes: map['finishedRoutes'] ?? 0,
      objectivesVisited: map['objectivesVisited'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthenticatedUser.fromJson(String source) => AuthenticatedUser.fromMap(json.decode(source));
}

class OAuthUser {
  String username;
  String email;
  String token;
  String iconUrl;
  bool isFacebook;
  bool isGoogle;

  OAuthUser(this.username, this.email, this.iconUrl);
}

class UserIcon {
  int id;
  String name;
  DateTime createdOn;
  Uint8List imageBlob;

  UserIcon.fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.name = json["name"];
    this.createdOn = json["created_on"];
    this.imageBlob = json["blob"];
  }
}

class FacebookUser {
  String email;
  String photo;
  String displayName;
  String id;

  FacebookUser.fromJson(Map<String, dynamic> json)
      : email = json["email"],
        //photo = json["picture"],
        displayName = json["name"],
        id = json["id"];
}

class SystemValue {
  String key;
  String value;
  int userId;
  SystemValue({this.key, this.value, this.userId});

  Map<String, dynamic> toMap() {
    return {'key': key, 'value': value, 'userId': userId};
  }

  factory SystemValue.fromMap(Map<String, dynamic> map) {
    return SystemValue(
      key: map['key'] ?? '',
      value: map['value'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SystemValue.fromJson(String source) => SystemValue.fromMap(json.decode(source));
}
