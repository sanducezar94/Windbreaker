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
