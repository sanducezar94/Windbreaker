import 'dart:io';

import 'package:fablebike/pages/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/drawer.dart';
import 'package:path/path.dart' as p;

class HomeScreen extends StatelessWidget {
  static const String route = '/home';

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthenticatedUser>(context);

    bool profilePicExists = File(user.username + '.jpg').existsSync();
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      drawer: buildDrawer(context, route),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  verticalDirection: VerticalDirection.up,
                  children: [
                    user.icon != 'none'
                        ? FutureBuilder<File>(
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Image.file(
                                    snapshot.data,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.contain,
                                  );
                                } else {
                                  return Icon(Icons.ac_unit_rounded);
                                }
                              }
                            },
                            future: getProfileImage(user))
                        : Icon(Icons.ac_unit_rounded),
                    Text('Hello ' + user.username)
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, ImagePickerScreen.route);
                        },
                        child: Icon(Icons.add_a_photo))
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<File> getProfileImage(AuthenticatedUser user) async {
  var appDir = await getApplicationDocumentsDirectory();
  var filePath = p.join(appDir.path, "user_images/" + user.icon);

  if (File(filePath).existsSync()) {
    return File(filePath);
  }
  return null;
}
