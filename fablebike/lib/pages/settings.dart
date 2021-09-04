import 'dart:math';
import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/bloc/event_constants.dart';
import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/pages/sections/rounded_button.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/card_builder.dart';
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
    var boxShadow = BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.06), spreadRadius: 6, blurRadius: 6, offset: Offset(0, 4));
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    double smallDivider = 12.5;
    double bigDivider = 25.0;
    var buttonRadius = Radius.circular(12.0);
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
              child: SingleChildScrollView(
                  child: Padding(
            child: Container(
              child: Column(
                children: [
                  CardBuilder.buildProfileBar(context, 'Panou de control', 'Schimba setarile.'),
                  SizedBox(height: bigDivider),
                  Row(children: [
                    Text(
                      context.read<LanguageManager>().settingAccount,
                      style: Theme.of(context).textTheme.headline2,
                      textAlign: TextAlign.start,
                    )
                  ]),
                  SizedBox(height: smallDivider),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(buttonRadius), color: Colors.white, boxShadow: [boxShadow]),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  child: Text(
                                    context.read<LanguageManager>().settingPhoto,
                                    style: TextStyle(fontSize: 18.0, color: Theme.of(context).accentColor.withOpacity(0.66), fontFamily: 'Nunito'),
                                  ),
                                  padding: EdgeInsets.only(left: 10),
                                )),
                            flex: 8),
                        Expanded(
                          child: RoundedButtonWidget(
                            child: Icon(Icons.photo_camera_back_outlined, color: Colors.white),
                            width: width,
                            onpressed: () async {
                              Navigator.pushNamed(context, ImagePickerScreen.route).then((value) {
                                setState(() {});
                              });
                            },
                          ),
                          flex: 2,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: bigDivider),
                  Row(children: [
                    Text(
                      context.read<LanguageManager>().settingPreferences,
                      style: Theme.of(context).textTheme.headline2,
                      textAlign: TextAlign.start,
                    )
                  ]),
                  SizedBox(height: smallDivider),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(buttonRadius), color: Colors.white, boxShadow: [boxShadow]),
                    child: Row(
                      children: [
                        Expanded(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  child: Text(
                                    context.read<LanguageManager>().settingDataUsageLow,
                                    style: TextStyle(fontSize: 18.0, color: Theme.of(context).accentColor.withOpacity(0.66), fontFamily: 'Nunito'),
                                  ),
                                  padding: EdgeInsets.only(left: 10),
                                )),
                            flex: 8),
                        Expanded(
                          child: RoundedButtonWidget(
                            child: Text('On'),
                            width: width,
                            onpressed: () async {
                              var confirm = await showDialog(context: context, builder: (_) => ConfirmDialog());

                              if (confirm) {
                                var dbDir = await getDatabasesPath();
                                var dbPath = path.join(dbDir, "fablebike.db");

                                await deleteDatabase(dbPath);
                                await DatabaseService().closeConnection();
                              }
                            },
                          ),
                          flex: 2,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: smallDivider),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(buttonRadius), color: Colors.white, boxShadow: [boxShadow]),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  child: Text(
                                    context.read<LanguageManager>().settingCache,
                                    style: TextStyle(fontSize: 18.0, color: Theme.of(context).accentColor.withOpacity(0.66), fontFamily: 'Nunito'),
                                  ),
                                  padding: EdgeInsets.only(left: 10),
                                )),
                            flex: 8),
                        Expanded(
                          child: RoundedButtonWidget(
                            child: Icon(Icons.delete, color: Colors.white),
                            width: width,
                            onpressed: () async {
                              var confirm = await showDialog(context: context, builder: (_) => ConfirmDialog());

                              if (confirm) {
                                var dbDir = await getDatabasesPath();
                                var dbPath = path.join(dbDir, "fablebike.db");

                                await deleteDatabase(dbPath);
                                await DatabaseService().closeConnection();
                              }
                            },
                          ),
                          flex: 2,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: smallDivider),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(buttonRadius), color: Colors.white, boxShadow: [boxShadow]),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  child: Text(
                                    context.read<LanguageManager>().settingLanguage,
                                    style: TextStyle(fontSize: 18.0, color: Theme.of(context).accentColor.withOpacity(0.6), fontFamily: 'Nunito'),
                                  ),
                                  padding: EdgeInsets.only(left: 10),
                                )),
                            flex: 8),
                        Expanded(
                          child: RoundedButtonWidget(
                            child: user.isRomanianLanguage ? Text('EN') : Text('RO'),
                            width: width,
                            onpressed: () async {
                              await this._changeLanguage();
                              context.read<LanguageManager>().language = user.isRomanianLanguage ? 'RO' : 'EN';
                              Provider.of<MainBloc>(context, listen: false).objectiveEventSync.add(Constants.NavigationRefresh);
                              setState(() {});
                            },
                          ),
                          flex: 2,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: bigDivider),
                  Row(children: [
                    Text(
                      'Altele',
                      style: Theme.of(context).textTheme.headline2,
                      textAlign: TextAlign.start,
                    )
                  ]),
                  SizedBox(height: smallDivider),
                  Container(
                      width: width,
                      height: 40,
                      child: RoundedButtonWidget(
                          child: Align(
                            child: Text(
                              context.read<LanguageManager>().settingPresentation,
                              style: TextStyle(fontSize: 18.0, color: Colors.white, fontFamily: 'Nunito'),
                            ),
                            alignment: Alignment.topCenter,
                          ),
                          width: width,
                          onpressed: () async {})),
                  SizedBox(height: smallDivider),
                  Container(
                      width: width,
                      height: 40,
                      child: RoundedButtonWidget(
                        child: Text(
                          context.read<LanguageManager>().settingGDPR,
                          style: TextStyle(fontSize: 18.0, color: Colors.white, fontFamily: 'Nunito'),
                        ),
                        width: width,
                        onpressed: () async {
                          Navigator.pushNamed(context, ImagePickerScreen.route).then((value) {
                            setState(() {});
                          });
                        },
                      )),
                  SizedBox(height: smallDivider),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            Provider.of<AuthenticationService>(context, listen: false).signOut();
                          },
                          style: OutlinedButton.styleFrom(
                              shadowColor: Theme.of(context).shadowColor.withOpacity(0.3),
                              elevation: 5,
                              backgroundColor: Colors.white,
                              textStyle: TextStyle(fontSize: 14),
                              primary: Theme.of(context).primaryColor,
                              side: BorderSide(style: BorderStyle.solid, color: Theme.of(context).primaryColorDark, width: 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
                          child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                child: Text(
                                  context.read<LanguageManager>().settingLogout,
                                  style: TextStyle(fontSize: 18.0, color: Theme.of(context).primaryColorDark, fontFamily: 'Nunito'),
                                ),
                                padding: EdgeInsets.only(left: 10),
                              )),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width,
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          ))),
        ));
  }
}
