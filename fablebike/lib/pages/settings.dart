import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/widgets/drawer.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  static const route = '/settings';
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: ColorfulSafeArea(
            overflowRules: OverflowRules.all(true),
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Scaffold(
                appBar: AppBar(title: Text('Setari')),
                body: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Filtre prestabilite'), flex: 2),
                        Expanded(
                            child: ElevatedButton(
                              child: Text('tet'),
                              onPressed: () {},
                            ),
                            flex: 1)
                      ],
                    )
                  ],
                ),
                drawer: buildDrawer(context, '/settings'))));
  }
}
