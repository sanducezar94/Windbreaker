import 'dart:io';
import 'dart:typed_data';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/pages/settings.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/pages/routes.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import '../pages/home.dart';

Widget _buildMenuItem(BuildContext context, Widget title, String routeName, String currentRoute) {
  var isSelected = routeName == currentRoute;

  return ListTile(
    title: title,
    selected: isSelected,
    onTap: () {
      if (isSelected) {
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, routeName);
      }
    },
  );
}

Drawer buildDrawer(BuildContext context, String currentRoute) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        DrawerHeader(
          child: Center(
              child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<Image>(
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(48.0),
                              child: InkWell(child: snapshot.data),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                      future: getProfileImage(context.read<AuthenticatedUser>())),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(child: Text(context.read<AuthenticatedUser>().username), padding: EdgeInsets.all(8.0)),
              ]),
            ],
          )),
        ),
        TextButton(
            onPressed: () {
              context.read<AuthenticationService>().signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
            },
            child: Text('Sign Out')),
        _buildMenuItem(context, const Text('Profile'), HomeScreen.route, currentRoute),
        _buildMenuItem(context, const Text('Rute'), RoutesScreen.route, currentRoute),
        _buildMenuItem(context, const Text('Setari'), '/settings', currentRoute),
      ],
    ),
  );
}

Future<Image> getProfileImage(AuthenticatedUser user) async {
  try {
    imageCache.clear();

    var db = await DatabaseService().database;

    var profilePic = await db.query('usericon', where: 'user_id = ? and is_profile = ?', whereArgs: [user.id, 1], columns: ['blob']);

    if (profilePic.length == 0) {
      return Image.asset('assets/icons/user.png', height: 96, width: 96, fit: BoxFit.contain);
    }

    return Image.memory(profilePic.first["blob"], height: 96, width: 96, fit: BoxFit.contain);
  } on Exception {
    return null;
  }
}
