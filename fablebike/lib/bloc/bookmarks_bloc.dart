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
  List<Objective> _objectives;
  List<Objective> _initialObjectives;
  final _bookmarkStateController = StreamController<List<Objective>>();

  StreamSink<List<Objective>> get _input => _bookmarkStateController.sink;
  Stream<List<Objective>> get output => _bookmarkStateController.stream;

  final _bookmarkEventController = StreamController<BookmarkBlocEvent>();
  Sink<BookmarkBlocEvent> get bookmarkEventSync => _bookmarkEventController.sink;

  BookmarkBloc() {
    _bookmarkEventController.stream.listen((event) async {
      await _mapEventToState(event);
    });
  }

  Future<void> _mapEventToState(BookmarkBlocEvent event) async {
    List<Objective> _returnList = [];
    switch (event.eventType) {
      case BookmarkEventType.BookmarkInitializeEvent:
        _returnList = await _getBookmarks(event.args['user_id']);
        _initialObjectives = _returnList.toList();
        break;
      case BookmarkEventType.BookmarkDeleteEvent:
        _returnList = _objectives.where((element) => element.id != event.args['index']).toList();
        _initialObjectives = _returnList.toList();
        break;
      case BookmarkEventType.BookmarkSearchEvent:
        if (_initialObjectives == null || _initialObjectives.isEmpty) break;
        var searchQuery = event.args['search_query'].toString().toLowerCase();
        _returnList = _initialObjectives.where((c) => c.name.toLowerCase().contains(searchQuery)).toList();
        break;
    }
    _input.add(_returnList);
  }

  Future<List<Objective>> _getBookmarks(int userId) async {
    try {
      var db = await DatabaseService().database;
      var bookmarks = await db.query('objectivebookmark');
      var objectiveRows = await db.rawQuery('SELECT * FROM objectivebookmark pb INNER JOIN objective p ON p.id = pb.objective_id WHERE pb.user_id = $userId');
      var objectives = List.generate(objectiveRows.length, (i) => Objective.fromJson(objectiveRows[i]));

      return objectives;
    } on Exception {
      return [];
    }
  }

  void dispose() {
    _bookmarkEventController.close();
    _bookmarkStateController.close();
  }
}
