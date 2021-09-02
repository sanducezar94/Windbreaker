import 'dart:async';

import 'package:fablebike/bloc/event_constants.dart';
import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/pages/routes.dart';
import 'package:fablebike/pages/sections/gradient_icon.dart';
import 'package:fablebike/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'objectives.dart';

class HomeWrapper extends StatefulWidget {
  HomeWrapper({Key key}) : super(key: key);

  @override
  _HomeWrapperState createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  PageController _pageController = PageController();
  List<Widget> _screens = [HomeScreen(), ObjectivesScreen(), RoutesScreen(), SettingsScreen()];
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
        child: Padding(
            child: ClipRRect(
                child: Container(
                    child: BottomNavigationBar(
                        onTap: _onItemTapped,
                        iconSize: 42,
                        selectedIconTheme: IconThemeData(size: 46),
                        type: BottomNavigationBarType.fixed,
                        showUnselectedLabels: false,
                        selectedLabelStyle: TextStyle(fontFamily: 'Lato', color: Colors.black),
                        showSelectedLabels: false,
                        unselectedItemColor: Theme.of(context).accentColor.withOpacity(0.75),
                        selectedItemColor: Theme.of(context).primaryColor,
                        currentIndex: _selectedIndex,
                        items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: _selectedIndex == 0
                            ? GradientIcon(
                                Icons.home,
                                42,
                              )
                            : Icon(Icons.home_outlined),
                        label: context.read<LanguageManager>().appHome,
                      ),
                      BottomNavigationBarItem(
                        icon: _selectedIndex == 1
                            ? GradientIcon(
                                Icons.explore,
                                42,
                              )
                            : Icon(Icons.explore_outlined),
                        label: context.read<LanguageManager>().appExplore,
                      ),
                      BottomNavigationBarItem(
                        icon: _selectedIndex == 2
                            ? GradientIcon(
                                Icons.map,
                                42,
                              )
                            : Icon(Icons.map_outlined),
                        label: context.read<LanguageManager>().appRoutes,
                      ),
                      BottomNavigationBarItem(
                        icon: _selectedIndex == 3
                            ? GradientIcon(
                                Icons.settings,
                                42,
                              )
                            : Icon(Icons.settings_outlined),
                        label: context.read<LanguageManager>().appSettings,
                      ),
                    ])),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(0.0), topRight: Radius.circular(0.0))),
            padding: EdgeInsets.symmetric(horizontal: 0)),
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 3, spreadRadius: 6),
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
