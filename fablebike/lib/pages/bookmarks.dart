import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/bloc/bookmarks_bloc.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/widgets/card_builders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fablebike/models/route.dart';
import 'package:provider/provider.dart';

class BookmarksScreen extends StatefulWidget {
  static const route = '/bookmarks';
  BookmarksScreen({Key key}) : super(key: key);

  @override
  _BookmarksScreen createState() => _BookmarksScreen();
}

class _BookmarksScreen extends State<BookmarksScreen> {
  TextEditingController searchController = TextEditingController();
  final _bloc = BookmarkBloc();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Objective>> _getNearbyObjectives(AuthenticatedUser user) async {
      var db = await DatabaseService().database;

      var objectiveRows = await db.query('Objective');
      var objectives = List.generate(objectiveRows.length, (i) => Objective.fromJson(objectiveRows[i]));

      return objectives.take(5).toList();
    }

    var user = Provider.of<AuthenticatedUser>(context);
    double smallDivider = 10.0;
    double bigDivider = 20.0;

    if (!this._initialized) {
      _bloc.bookmarkEventSync.add(BookmarkBlocEvent(eventType: BookmarkEventType.BookmarkInitializeEvent, args: {'user_id': user.id}));
      this._initialized = true;
    }

    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SafeArea(
            child: Scaffold(
                body: SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        child: Column(children: [
                          CardBuilder.buildProfileBar(context, 'Obiective'),
                          SizedBox(height: bigDivider),
                          Container(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Material(
                                      child: TextField(
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.search),
                                            fillColor: Colors.white,
                                            hintStyle: TextStyle(fontSize: 16.0, color: Theme.of(context).accentColor.withOpacity(0.5)),
                                            filled: true,
                                            contentPadding: EdgeInsets.all(0),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                            hintText: 'Cauta obiectiv...'),
                                      ),
                                      shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                      borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                      elevation: 10.0,
                                    ),
                                    flex: 1)
                              ],
                            ),
                            height: 48,
                            width: 999,
                          ),
                          SizedBox(height: bigDivider),
                          Row(children: [
                            Text(
                              "Obiective populare",
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.start,
                            )
                          ]),
                          SizedBox(height: smallDivider),
                          FutureBuilder<List<Objective>>(
                              builder: (context, AsyncSnapshot<List<Objective>> snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  if (snapshot.hasData && snapshot.data != null) {
                                    return Column(
                                      children: [
                                        for (var i = 0; i < 5; i++) CardBuilder.buildlargeObjectiveCard(context, snapshot.data[i]),
                                      ],
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                              future: _getNearbyObjectives(user)),
                        ]))))));
  }
}
