import 'dart:async';

import 'package:fablebike/bloc/event_constants.dart';
import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/pages/bookmarks.dart';
import 'package:fablebike/pages/routes.dart';
import 'package:fablebike/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';
import 'explore.dart';
import 'home.dart';

class HomeWrapper extends StatefulWidget {
  HomeWrapper({Key key}) : super(key: key);

  @override
  _HomeWrapperState createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  PageController _pageController = PageController();
  List<Widget> _screens = [HomeScreen(), BookmarksScreen(), RoutesScreen(), SettingsScreen()];
  int _selectedIndex = 0;
  StreamSubscription<String> subscription;

  _onItemTapped(int selectedIndex) {
    _pageController.jumpToPage(selectedIndex);
  }

  _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    subscription = context.read<MainBloc>().output.listen((event) {
      if (event == Constants.NavigationRefresh) {
        setState(() {});
      }
      if (event == Constants.NavigateToExplore) {
        _pageController.jumpToPage(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    BottomNavigationBar _buildBottomBar() {
      double w = 40;
      double h = 40;

      return BottomNavigationBar(
          onTap: _onItemTapped,
          iconSize: 18,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          unselectedItemColor: Theme.of(context).accentColor,
          selectedItemColor: Theme.of(context).primaryColor,
          currentIndex: _selectedIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon:
                  _selectedIndex == 0 ? Image.asset('assets/icons/home_h.png', width: w, height: h) : Image.asset('assets/icons/home.png', width: w, height: h),
              label: context.read<LanguageManager>().appHome,
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 1
                  ? Image.asset('assets/icons/explore_h.png', width: w, height: h)
                  : Image.asset('assets/icons/explore.png', width: w, height: h),
              label: context.read<LanguageManager>().appExplore,
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 2 ? Image.asset('assets/icons/poi_h.png', width: w, height: h) : Image.asset('assets/icons/poi.png', width: w, height: h),
              label: context.read<LanguageManager>().appRoutes,
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 3
                  ? Image.asset('assets/icons/settings_h.png', width: w, height: h)
                  : Image.asset('assets/icons/settings.png', width: w, height: h),
              label: context.read<LanguageManager>().appSettings,
            ),
          ]);
    }

    return Scaffold(
      bottomNavigationBar: _buildBottomBar(),
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }
}
