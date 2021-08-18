import 'dart:math';
import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/bloc/event_constants.dart';
import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class SettingsScreen extends StatefulWidget {
  static const route = '/settings';
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AuthenticatedUser user;

  @override
  void initState() {
    super.initState();
    user = context.read<AuthenticatedUser>();
  }

  Future<void> _changeLanguage() async {
    var db = await DatabaseService().database;

    if (user.isRomanianLanguage) {
      await db.update('SystemValue', {'value': '0'}, where: 'user_id = ? and key = ?', whereArgs: [user.id, 'language']);
      user.isRomanianLanguage = false;
    } else {
      await db.update('SystemValue', {'value': '1'}, where: 'user_id = ? and key = ?', whereArgs: [user.id, 'language']);
      user.isRomanianLanguage = true;
    }
  }

  Future<void> _changeDataUsage() async {
    var db = await DatabaseService().database;

    if (user.lowDataUsage) {
      await db.update('SystemValue', {'value': '0'}, where: 'user_id = ? and key = ?', whereArgs: [user.id, 'datausage']);
      user.lowDataUsage = false;
    } else {
      await db.update('SystemValue', {'value': '1'}, where: 'user_id = ? and key = ?', whereArgs: [user.id, 'datausage']);
      user.lowDataUsage = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Center(
                  child: Text(
                context.read<LanguageManager>().appSettings,
                style: Theme.of(context).textTheme.headline3,
              )),
              shadowColor: Colors.white10,
              backgroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
                child: Padding(
              child: Container(
                child: Column(
                  children: [
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(18.0)),
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
                            child: Padding(
                                child: Column(
                                  children: [
                                    Spacer(flex: 2),
                                    Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                                          child: Row(children: [
                                            Icon(Icons.account_box_rounded),
                                            SizedBox(width: 5),
                                            Text(
                                              context.read<LanguageManager>().settingAccount,
                                              style: Theme.of(context).textTheme.headline5,
                                              textAlign: TextAlign.start,
                                            )
                                          ]),
                                        ),
                                        flex: 4),
                                    Expanded(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                                child: OutlinedButton(
                                                    onPressed: () {},
                                                    style: OutlinedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.only(topLeft: Radius.circular(16.0), bottomLeft: Radius.circular(16.0)))),
                                                    child: Text(
                                                      context.read<LanguageManager>().settingPhoto,
                                                      textAlign: TextAlign.left,
                                                      style: Theme.of(context).textTheme.headline4,
                                                    )),
                                                flex: 8),
                                            Expanded(
                                              child: ElevatedButton(
                                                child: Icon(Icons.camera_alt_outlined),
                                                onPressed: () async {
                                                  Navigator.pushNamed(context, ImagePickerScreen.route).then((value) {
                                                    setState(() {});
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    primary: Theme.of(context).primaryColorDark,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.only(topRight: Radius.circular(16.0), bottomRight: Radius.circular(16.0)))),
                                              ),
                                              flex: 2,
                                            )
                                          ],
                                        ),
                                        flex: 10),
                                    Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: ElevatedButton(
                                                    onPressed: () {},
                                                    style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
                                                    child: Stack(
                                                      children: [
                                                        Align(
                                                          child: Text(context.read<LanguageManager>().settingGDPR,
                                                              style: TextStyle(color: Colors.white, fontSize: 16)),
                                                          alignment: Alignment.centerLeft,
                                                        ),
                                                        Align(
                                                          child: Text('➤', style: TextStyle(color: Colors.white, fontSize: 14)),
                                                          alignment: Alignment.centerRight,
                                                        ),
                                                      ],
                                                    )),
                                                flex: 1),
                                          ],
                                        ),
                                        flex: 6),
                                    Spacer(
                                      flex: 4,
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 10))),
                        flex: 40),
                    Spacer(
                      flex: 10,
                    ),
                    Expanded(
                        flex: 50,
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(18.0)),
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 4))]),
                            child: Padding(
                              child: Column(
                                children: [
                                  Spacer(flex: 1),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                                      child: Row(children: [
                                        Icon(Icons.settings),
                                        SizedBox(width: 5),
                                        Text(
                                          context.read<LanguageManager>().settingPreferences,
                                          style: Theme.of(context).textTheme.headline5,
                                          textAlign: TextAlign.start,
                                        )
                                      ]),
                                    ),
                                    flex: 4,
                                  ),
                                  Spacer(flex: 1),
                                  Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                              child: OutlinedButton(
                                                  onPressed: null,
                                                  style: OutlinedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.only(
                                                              topRight: Radius.circular(6.0),
                                                              bottomRight: Radius.circular(6.0),
                                                              topLeft: Radius.circular(16.0),
                                                              bottomLeft: Radius.circular(16.0)))),
                                                  child: Text(
                                                    context.read<LanguageManager>().settingDataUsageLow,
                                                    textAlign: TextAlign.left,
                                                    style: Theme.of(context).textTheme.headline4,
                                                  )),
                                              flex: 3),
                                          Expanded(
                                            child: FlutterSwitch(
                                                activeColor: Theme.of(context).primaryColorDark,
                                                borderRadius: 6,
                                                activeTextFontWeight: FontWeight.normal,
                                                inactiveTextFontWeight: FontWeight.normal,
                                                activeTextColor: Colors.white,
                                                value: user.lowDataUsage,
                                                showOnOff: true,
                                                padding: 8.0,
                                                onToggle: (val) async {
                                                  await _changeDataUsage();
                                                  setState(() {});
                                                }),
                                          )
                                        ],
                                      ),
                                      flex: 5),
                                  Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                              child: OutlinedButton(
                                                  onPressed: null,
                                                  style: OutlinedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), bottomLeft: Radius.circular(16.0)))),
                                                  child: Text(
                                                    context.read<LanguageManager>().settingCache,
                                                    textAlign: TextAlign.left,
                                                    style: Theme.of(context).textTheme.headline4,
                                                  )),
                                              flex: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              child: Icon(Icons.delete),
                                              onPressed: () async {
                                                var confirm = await showDialog(context: context, builder: (_) => ConfirmDialog());

                                                if (confirm) {
                                                  var dbDir = await getDatabasesPath();
                                                  var dbPath = path.join(dbDir, "fablebike.db");

                                                  await deleteDatabase(dbPath);
                                                  await DatabaseService().closeConnection();
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  primary: Theme.of(context).primaryColorDark,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(topRight: Radius.circular(16.0), bottomRight: Radius.circular(16.0)))),
                                            ),
                                            flex: 2,
                                          )
                                        ],
                                      ),
                                      flex: 5),
                                  Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                              child: OutlinedButton(
                                                  onPressed: null,
                                                  style: OutlinedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), bottomLeft: Radius.circular(16.0)))),
                                                  child: Text(
                                                    context.read<LanguageManager>().settingLanguage,
                                                    textAlign: TextAlign.left,
                                                    style: Theme.of(context).textTheme.headline4,
                                                  )),
                                              flex: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              child: user.isRomanianLanguage ? Text('EN') : Text('RO'),
                                              onPressed: () async {
                                                await this._changeLanguage();
                                                context.read<LanguageManager>().language = user.isRomanianLanguage ? 'RO' : 'EN';
                                                Provider.of<MainBloc>(context, listen: false).objectiveEventSync.add(Constants.NavigationRefresh);
                                                setState(() {});
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  primary: Theme.of(context).primaryColorDark,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(topRight: Radius.circular(16.0), bottomRight: Radius.circular(16.0)))),
                                            ),
                                            flex: 2,
                                          )
                                        ],
                                      ),
                                      flex: 5),
                                  Spacer(flex: 2)
                                ],
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ))),
                    Spacer(
                      flex: 10,
                    ),
                    Expanded(
                      flex: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              child: Text(context.read<LanguageManager>().settingPresentation),
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Spacer(flex: 2),
                    Expanded(
                      flex: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                                onPressed: () async {
                                  Provider.of<AuthenticationService>(context, listen: false).signOut();
                                },
                                style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    textStyle: TextStyle(fontSize: 14),
                                    primary: Theme.of(context).primaryColor,
                                    side: BorderSide(style: BorderStyle.solid, color: Theme.of(context).primaryColor, width: 1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
                                child: Text(context.read<LanguageManager>().settingLogout)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                height: height - 80,
                width: MediaQuery.of(context).size.width,
              ),
              padding: EdgeInsets.all(20.0),
            ))));
  }
}
