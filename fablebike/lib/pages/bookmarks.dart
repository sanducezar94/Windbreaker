import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/bloc/bookmarks_bloc.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/widgets/drawer.dart';
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
    var user = Provider.of<AuthenticatedUser>(context);

    Widget _buildRoute(BuildContext context, PointOfInterest bookmark) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          ListTile(
            leading: Icon(Icons.photo_album),
            title: Text(bookmark.name),
            subtitle: Text(bookmark.description),
          ),
          ButtonBar(alignment: MainAxisAlignment.start, children: [
            ElevatedButton(
                child: Text('Mai multe...'),
                onPressed: () async {
                  Navigator.pushNamed(context, 'poi', arguments: bookmark).then((value) {
                    _bloc.bookmarkEventSync.add(BookmarkBlocEvent(eventType: BookmarkEventType.BookmarkInitializeEvent, args: {'user_id': user.id}));
                  });
                })
          ]),
        ]),
      );
    }

    if (!this._initialized) {
      _bloc.bookmarkEventSync.add(BookmarkBlocEvent(eventType: BookmarkEventType.BookmarkInitializeEvent, args: {'user_id': user.id}));
      this._initialized = true;
    }

    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
            appBar: AppBar(title: Text('Map')),
            body: SingleChildScrollView(
                child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (context) {
                      _bloc.bookmarkEventSync
                          .add(BookmarkBlocEvent(eventType: BookmarkEventType.BookmarkSearchEvent, args: {'search_query': searchController.text}));
                    },
                    controller: searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(24.0))),
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: this.searchController != null && this.searchController.text.length > 0
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  this.searchController.text = '';
                                });
                              },
                              icon: Icon(Icons.cancel))
                          : null,
                      hintText: 'Cauta',
                    ),
                  ),
                ),
                StreamBuilder(
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      List<Widget> children = [];
                      var filteredList = snapshot.data;
                      for (var i = 0; i < filteredList.length; i++) {
                        children.add(_buildRoute(context, filteredList[i]));
                      }
                      return Column(children: children);
                    } else {
                      return Text('Loading...');
                    }
                  },
                  initialData: [],
                  stream: _bloc.output,
                )
              ],
            ))));
  }
}
