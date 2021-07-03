import 'package:fablebike/models/route.dart';
import 'package:fablebike/services/database_service.dart';
import 'dart:async';

enum ObjectiveEventType { ObjectiveInitializeEvent, ObjectiveSearchEvent }

class ObjectiveBlocEvent {
  final ObjectiveEventType eventType;
  final Map<String, dynamic> args;

  ObjectiveBlocEvent({this.eventType, this.args});
}

class ObjectiveBloc {
  List<Objective> _bookmarks;
  List<Objective> _initialBookmarks;
  final _objectiveStateController = StreamController<List<Objective>>();

  StreamSink<List<Objective>> get _input => _objectiveStateController.sink;
  Stream<List<Objective>> get output => _objectiveStateController.stream;

  final _objectiveEventController = StreamController<ObjectiveBlocEvent>();
  Sink<ObjectiveBlocEvent> get bookmarkEventSync => _objectiveEventController.sink;

  BookmarkBloc() {
    _objectiveEventController.stream.listen((event) async {
      await _mapEventToState(event);
    });
  }

  Future<void> _mapEventToState(ObjectiveBlocEvent event) async {
    List<Objective> _returnList = [];
    switch (event.eventType) {
      case ObjectiveEventType.ObjectiveInitializeEvent:
        _returnList = await _getAllObjectives();
        _initialBookmarks = _returnList.toList();
        break;
      case ObjectiveEventType.ObjectiveSearchEvent:
        _returnList = _bookmarks.where((element) => element.id != event.args['index']).toList();
        _initialBookmarks = _returnList.toList();
        break;
    }
    _input.add(_returnList);
  }

  Future<List<Objective>> _getAllObjectives() async {
    var db = await DatabaseService().database;

    var objectiveRows = await db.rawQuery('SELECT * FROM objective');
    var objectives = List.generate(objectiveRows.length, (i) => Objective.fromJson(objectiveRows[i]));
    return objectives;
  }

  void dispose() {
    _objectiveEventController.close();
    _objectiveStateController.close();
  }
}
