import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  static const String route = '/landing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Welcome')),
        body: Center(
          child: TextButton(
            child: Text('Sign in'),
            onPressed: () {},
          ),
        ));
  }
}
