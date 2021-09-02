import 'package:fablebike/models/route.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/math_service.dart' as mapMath;
import 'package:latlong/latlong.dart';
import 'dart:async';

enum ObjectiveEventType { ObjectiveInitializeEvent, ObjectiveToggleBookmark, ObjectiveGetNearby, ObjectiveSearchEvent, ObjectiveRateEvent }

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
    try {
      switch (event.eventType) {
        case ObjectiveEventType.ObjectiveInitializeEvent:
          _returnList = await _getAllObjectives(event.args['user_id']);
          _initialObjectives = _returnList.toList();
          break;
        case ObjectiveEventType.ObjectiveGetNearby:
          _returnList = await _getNearbyObjectives(event.args['user_id'], event.args['location'] as LatLng);
          break;
        case ObjectiveEventType.ObjectiveToggleBookmark:
          var objective = _initialObjectives.where((c) => c.id == event.args['id']).first;
          await _toggleBookmark(objective, event.args['user_id']);
          _returnList = _initialObjectives;
          break;
        case ObjectiveEventType.ObjectiveSearchEvent:
          if (_initialObjectives == null || _initialObjectives.isEmpty) break;
          var searchQuery = event.args['search_query'].toString().toLowerCase();
          _returnList = _initialObjectives.where((c) => c.name.toLowerCase().contains(searchQuery)).toList();
          break;
        case ObjectiveEventType.ObjectiveRateEvent:
          var objective = _initialObjectives.where((c) => c.id == event.args['id']).first;
          if (objective != null) objective.rating = event.args['rating'];
          _returnList = _initialObjectives;
          break;
      }
    } on Exception {
      _returnList = [];
    }
    _input.add(_returnList);
  }

  Future<List<Objective>> _getAllObjectives(int userId) async {
    try {
      var db = await DatabaseService().database;

      var objectiveRows = await db.query('objective');
      var objectives = List.generate(objectiveRows.length, (i) => Objective.fromJson(objectiveRows[i]));

      for (var i = 0; i < objectives.length; i++) {
        var objective = await db.query('objectivebookmark', where: 'objective_id = ? and user_id = ?', whereArgs: [objectives[i].id, userId]);
        if (objective.length > 0) objectives[i].is_bookmarked = true;
      }
      return objectives;
    } on Exception {
      return [];
    }
  }

  Future<bool> _toggleBookmark(Objective objective, int userId) async {
    try {
      var db = await DatabaseService().database;
      if (objective.is_bookmarked) {
        await db.delete('objectivebookmark', where: 'objective_id = ? and user_id = ?', whereArgs: [objective.id, userId]);
      } else {
        await db.insert('objectivebookmark', {'objective_id': objective.id, 'user_id': userId});
      }
      objective.is_bookmarked = !objective.is_bookmarked;
      return true;
    } on Exception {
      return false;
    }
  }

  Future<List<Objective>> _getNearbyObjectives(int userId, LatLng location) async {
    try {
      var db = await DatabaseService().database;

      var bookmarkRows = await db.rawQuery('SELECT * FROM objectivebookmark pb INNER JOIN objective p ON p.id = pb.objective_id WHERE pb.user_id = $userId');
      var bookmarks = List.generate(bookmarkRows.length, (i) => Objective.fromJson(bookmarkRows[i]));

      var objectiveRows = await db.query('Objective');
      var objectives = List.generate(objectiveRows.length, (i) => Objective.fromJson(objectiveRows[i]));

      if (bookmarks.length > 0) {
        objectives.forEach((element) {
          element.is_bookmarked = bookmarks.where((el) => el.id == element.id).isNotEmpty;
        });
      }
      return objectives.where((c) => mapMath.calculateDistance(location.latitude, location.longitude, c.latitude, c.longitude) < 10).toList();
    } on Exception {
      return [];
    }
  }

  void dispose() {
    _objectiveEventController.close();
    _objectiveStateController.close();
  }
}
