import 'package:flutter/material.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:provider/provider.dart';
import '../widgets/drawer.dart';
import 'image_screen.dart';

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
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text('Bicicheta mea.'),
            ),
            Column(
              children: [Text('Hello ' + user.username)],
            ),
            FilePicker(user: user)
          ],
        ),
      ),
    );
  }
}
