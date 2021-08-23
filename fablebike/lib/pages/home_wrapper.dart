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
    Widget _buildBottomBar() {
      double w = 32;
      double h = 32;

      return Container(
        child: ClipRRect(
            child: Container(
                child: BottomNavigationBar(
                    onTap: _onItemTapped,
                    iconSize: 36,
                    selectedIconTheme: IconThemeData(size: 42),
                    type: BottomNavigationBarType.fixed,
                    showUnselectedLabels: true,
                    selectedLabelStyle: TextStyle(fontFamily: 'Lato', color: Colors.black),
                    showSelectedLabels: true,
                    unselectedItemColor: Theme.of(context).accentColor.withOpacity(0.75),
                    selectedItemColor: Theme.of(context).accentColor,
                    currentIndex: _selectedIndex,
                    items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: _selectedIndex == 0 ? Icon(Icons.home) : Icon(Icons.home_outlined),
                    label: context.read<LanguageManager>().appHome,
                  ),
                  BottomNavigationBarItem(
                    icon: _selectedIndex == 1 ? Icon(Icons.explore) : Icon(Icons.explore_outlined),
                    label: context.read<LanguageManager>().appExplore,
                  ),
                  BottomNavigationBarItem(
                    icon: _selectedIndex == 2 ? Icon(Icons.map) : Icon(Icons.map_outlined),
                    label: context.read<LanguageManager>().appRoutes,
                  ),
                  BottomNavigationBarItem(
                    icon: _selectedIndex == 3 ? Icon(Icons.settings) : Icon(Icons.settings_outlined),
                    label: context.read<LanguageManager>().appSettings,
                  ),
                ])),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.1), blurRadius: 3, spreadRadius: 6),
          ],
        ),
      );
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
