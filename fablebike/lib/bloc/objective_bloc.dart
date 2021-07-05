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
  List<Objective> _objectives;
  List<Objective> _initialObjectives;
  final _objectiveStateController = StreamController<List<Objective>>.broadcast();

  StreamSink<List<Objective>> get _input => _objectiveStateController.sink;
  Stream<List<Objective>> get output => _objectiveStateController.stream;

  final _objectiveEventController = StreamController<ObjectiveBlocEvent>();
  Sink<ObjectiveBlocEvent> get objectiveEventSync => _objectiveEventController.sink;

  ObjectiveBloc() {
    _objectiveEventController.stream.listen((event) async {
      await _mapEventToState(event);
    });
  }

  Future<void> _mapEventToState(ObjectiveBlocEvent event) async {
    List<Objective> _returnList = [];
    switch (event.eventType) {
      case ObjectiveEventType.ObjectiveInitializeEvent:
        _returnList = await _getAllObjectives();
        _initialObjectives = _returnList.toList();
        break;
      case ObjectiveEventType.ObjectiveSearchEvent:
        if (_initialObjectives == null || _initialObjectives.isEmpty) break;
        var searchQuery = event.args['search_query'].toString().toLowerCase();
        _returnList = _initialObjectives.where((c) => c.name.toLowerCase().contains(searchQuery)).toList();
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
