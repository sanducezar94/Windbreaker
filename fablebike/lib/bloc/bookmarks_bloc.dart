import 'package:fablebike/models/route.dart';
import 'package:fablebike/services/database_service.dart';
import 'dart:async';

enum BookmarkEventType { BookmarkInitializeEvent, BookmarkDeleteEvent, BookmarkSearchEvent }

class BookmarkBlocEvent {
  final BookmarkEventType eventType;
  final Map<String, dynamic> args;

  BookmarkBlocEvent({this.eventType, this.args});
}

class BookmarkBloc {
  List<PointOfInterest> _bookmarks;
  List<PointOfInterest> _initialBookmarks;
  final _bookmarkStateController = StreamController<List<PointOfInterest>>();

  StreamSink<List<PointOfInterest>> get _input => _bookmarkStateController.sink;
  Stream<List<PointOfInterest>> get output => _bookmarkStateController.stream;

  final _bookmarkEventController = StreamController<BookmarkBlocEvent>();
  Sink<BookmarkBlocEvent> get bookmarkEventSync => _bookmarkEventController.sink;

  BookmarkBloc() {
    _bookmarkEventController.stream.listen((event) async {
      await _mapEventToState(event);
    });
  }

  Future<void> _mapEventToState(BookmarkBlocEvent event) async {
    List<PointOfInterest> _returnList = [];
    switch (event.eventType) {
      case BookmarkEventType.BookmarkInitializeEvent:
        _returnList = await _getBookmarks(event.args['user_id']);
        _initialBookmarks = _returnList.toList();
        break;
      case BookmarkEventType.BookmarkDeleteEvent:
        _returnList = _bookmarks.where((element) => element.id != event.args['index']).toList();
        _initialBookmarks = _returnList.toList();
        break;
      case BookmarkEventType.BookmarkSearchEvent:
        if (_initialBookmarks == null || _initialBookmarks.isEmpty) break;
        var searchQuery = event.args['search_query'].toString().toLowerCase();
        _returnList = _initialBookmarks.where((c) => c.name.toLowerCase().contains(searchQuery)).toList();
        break;
    }
    _input.add(_returnList);
  }

  Future<List<PointOfInterest>> _getBookmarks(int userId) async {
    var db = await DatabaseService().database;

    var poiRows = await db.rawQuery('SELECT * FROM pointofinterestbookmark pb INNER JOIN pointofinterest p ON p.id = pb.poi_id WHERE pb.user_id = ${userId}');
    var pois = List.generate(poiRows.length, (i) => PointOfInterest.fromJson(poiRows[i]));
    return pois;
  }

  void dispose() {
    _bookmarkEventController.close();
    _bookmarkStateController.close();
  }
}
