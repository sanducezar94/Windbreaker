import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:provider/provider.dart';
import '../widgets/drawer.dart';

class HomeScreen extends StatelessWidget {
  static const String route = '/home';

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthenticatedUser>(context);
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
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
        ));
  }
}
