import 'package:fablebike/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/pages/routes.dart';
import '../pages/home.dart';

BottomNavigationBar routeBottomBar(BuildContext context, String currentRoute) {
  double w = 40;
  double h = 40;

  return BottomNavigationBar(
      onTap: (int index) {
        switch (index) {
          case 0:
            if (currentRoute == "poi") {
              if (currentRoute != ModalRoute.of(context).settings.name) {}
              return;
            }
            break;
          case 1:
            if (currentRoute == "elev") {
              if (currentRoute != ModalRoute.of(context).settings.name) {}
              return;
            }
            break;
          case 2:
            if (currentRoute == "conv") {
              if (currentRoute != ModalRoute.of(context).settings.name) {}
              return;
            }
            break;
        }
      },
      iconSize: 18,
      elevation: 36.0,
      selectedItemColor: Theme.of(context).primaryColor,
      currentIndex: currentRoute == "poi"
          ? 0
          : currentRoute == "elev"
              ? 1
              : 2,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: currentRoute != "poi" ? Image.asset('assets/icons/poi.png', width: w, height: h) : Image.asset('assets/icons/poi_h.png', width: w, height: h),
          label: 'Puncte de Interes',
        ),
        BottomNavigationBarItem(
          icon:
              currentRoute != "elev" ? Image.asset('assets/icons/elev.png', width: w, height: h) : Image.asset('assets/icons/elev_h.png', width: w, height: h),
          label: 'Elevatie',
        ),
        BottomNavigationBarItem(
          icon:
              currentRoute != "conv" ? Image.asset('assets/icons/conv.png', width: w, height: h) : Image.asset('assets/icons/conv_h.png', width: w, height: h),
          label: 'Comentarii',
        ),
      ]);
}
