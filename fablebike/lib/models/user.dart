import 'dart:typed_data';

class AuthenticatedUser {
  int id;
  String username;
  String email;
  String token;
  String icon;
  String roleTokens;

  List<int> ratedRoutes;
  List<int> ratedComments;

  AuthenticatedUser(int id, String user, String email, String token, String icon, String roles) {
    this.id = id;
    this.username = user;
    this.email = email;
    this.token = token;
    this.icon = icon;
    ratedRoutes = [];
    ratedComments = [];
    roleTokens = roles;
  }
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
