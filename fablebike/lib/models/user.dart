import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class AuthenticatedUser {
  int id;
  String username;
  String email;
  String token;
  String icon;
  String roleTokens;

  List<int> ratedRoutes;
  List<int> ratedComments;

  bool lowDataUsage;
  bool isRomanianLanguage;

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

  AuthenticatedUser(
    this.id,
    this.username,
    this.email,
    this.token,
    this.icon,
    this.roleTokens,
    this.ratedRoutes,
    this.ratedComments,
    this.lowDataUsage,
    this.isRomanianLanguage,
    this.distanceTravelled,
    this.finishedRoutes,
    this.objectivesVisited,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'token': token,
      'icon': icon,
      'roleTokens': roleTokens,
      'ratedRoutes': ratedRoutes,
      'ratedComments': ratedComments,
      'lowDataUsage': lowDataUsage,
      'isRomanianLanguage': isRomanianLanguage,
      'distanceTravelled': distanceTravelled,
      'finishedRoutes': finishedRoutes,
      'objectivesVisited': objectivesVisited,
    };
  }

  factory AuthenticatedUser.fromMap(Map<String, dynamic> map) {
    return AuthenticatedUser(
      map['id'] ?? 0,
      map['username'] ?? '',
      map['email'] ?? '',
      map['token'] ?? '',
      map['icon'] ?? '',
      map['roleTokens'] ?? '',
      List<int>.from(map['ratedRoutes'] ?? const []),
      List<int>.from(map['ratedComments'] ?? const []),
      map['lowDataUsage'] ?? false,
      map['isRomanianLanguage'] ?? false,
      map['distanceTravelled'] ?? 0.0,
      map['finishedRoutes'] ?? 0,
      map['objectivesVisited'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthenticatedUser.fromJson(String source) => AuthenticatedUser.fromMap(json.decode(source));
}

class OAuthUser {
  String username;
  String email;
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
