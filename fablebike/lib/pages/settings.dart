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

    if (user.normalDataUsage) {
      await db.update('SystemValue', {'value': '0'}, where: 'user_id = ? and key = ?', whereArgs: [user.id, 'datausage']);
      user.normalDataUsage = false;
    } else {
      await db.update('SystemValue', {'value': '1'}, where: 'user_id = ? and key = ?', whereArgs: [user.id, 'datausage']);
      user.normalDataUsage = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;

    double smallPadding = height * 0.0125;
    double bigPadding = height * 0.05;
    return Container(
        child: ColorfulSafeArea(
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
                  shadowColor: Colors.white54,
                  backgroundColor: Colors.white,
                ),
                body: Padding(
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: Column(
                              children: [
                                Padding(
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
                                SizedBox(
                                  height: smallPadding,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                        child: OutlinedButton(
                                            onPressed: () {},
                                            style: OutlinedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), bottomLeft: Radius.circular(16.0)))),
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
                                SizedBox(
                                  height: smallPadding,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  child: Text(context.read<LanguageManager>().settingGDPR, style: TextStyle(color: Colors.white, fontSize: 16)),
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
                              ],
                            ),
                            flex: 3),
                        Spacer(
                          flex: 1,
                        ),
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
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
                              SizedBox(
                                height: smallPadding,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                      child: OutlinedButton(
                                          onPressed: null,
                                          style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), bottomLeft: Radius.circular(16.0)))),
                                          child: Text(
                                            this.user.normalDataUsage
                                                ? context.read<LanguageManager>().settingDataUsageNormal
                                                : context.read<LanguageManager>().settingDataUsageLow,
                                            textAlign: TextAlign.left,
                                            style: Theme.of(context).textTheme.headline4,
                                          )),
                                      flex: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      child: Icon(this.user.normalDataUsage ? Icons.data_saver_off : Icons.data_saver_on),
                                      onPressed: () async {
                                        await _changeDataUsage();
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
                              SizedBox(
                                height: smallPadding,
                              ),
                              Row(
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
                              SizedBox(
                                height: smallPadding,
                              ),
                              Row(
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
                                      child: user.isRomanianLanguage ? Text('RO') : Text('EN'),
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
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
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
                        Expanded(
                          flex: 1,
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
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                  padding: EdgeInsets.all(20.0),
                ))));
  }
}
