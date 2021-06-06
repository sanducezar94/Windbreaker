import 'dart:io';

import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/pages/routes.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import '../pages/home.dart';

Widget _buildMenuItem(
    BuildContext context, Widget title, String routeName, String currentRoute) {
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
                  FutureBuilder<File>(
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(48.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, ImagePickerScreen.route);
                                },
                                child: Image.file(
                                  snapshot.data,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                      future:
                          getProfileImage(context.read<AuthenticatedUser>())),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(
                    child: Text(context.read<AuthenticatedUser>().username),
                    padding: EdgeInsets.all(8.0)),
              ]),
            ],
          )),
        ),
        TextButton(
            onPressed: () {
              context.read<AuthenticationService>().signOut();
              //Navigator.of(context).push((route) => route.isFirst);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/landing', (route) => false);
            },
            child: Text('Sign Out')),
        _buildMenuItem(
            context, const Text('Profile'), HomeScreen.route, currentRoute),
        _buildMenuItem(
            context, const Text('Rute'), RoutesScreen.route, currentRoute),
      ],
    ),
  );
}

Future<File> getProfileImage(AuthenticatedUser user) async {
  try {
    imageCache.clear();
    var storage = new StorageService();
    var filename = await storage.readValue(user.username + '-pic');

    if (filename != null) {
      var file = await storage.getFileFromPath("", filename);
      return file;
    }

    return null;
  } on Exception {
    return null;
  }
}
