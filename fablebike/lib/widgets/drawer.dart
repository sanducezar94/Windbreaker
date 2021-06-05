import 'package:flutter/material.dart';
import 'package:fablebike/pages/routes.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';

import '../pages/map.dart';
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
        Navigator.pushNamed(context, routeName);
      }
    },
  );
}

Drawer buildDrawer(BuildContext context, String currentRoute) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        const DrawerHeader(
          child: Center(
            child: Text('Header'),
          ),
        ),
        _buildMenuItem(
            context, const Text('Profile'), HomeScreen.route, currentRoute),
        _buildMenuItem(
            context, const Text('Rute'), RoutesScreen.route, currentRoute),
        TextButton(
            onPressed: () {
              context.read<AuthenticationService>().signOut();
              // Navigator.pushNamedAndRemoveUntil(
              //     context, '/landing', (route) => false);
            },
            child: Text('Sign Out'))
      ],
    ),
  );
}
