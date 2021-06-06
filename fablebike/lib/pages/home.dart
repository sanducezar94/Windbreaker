import 'dart:io';

import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/services/storage_service.dart';
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
                  children: [Text('Hello ' + user.username)],
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
