import 'package:fablebike/models/route.dart';
import 'package:fablebike/services/database_service.dart';
import 'dart:async';

enum RouteEventType { RouteInitializeEvent, RouteSearchEvent, RouteRateEvent }

class RouteBlocEvent {
  final RouteEventType eventType;
  final Map<String, dynamic> args;

  RouteBlocEvent({this.eventType, this.args});
}

class RouteBloc {
  List<BikeRoute> _routes;
  List<BikeRoute> _initialRoutes;
  final _routeStateController = StreamController<List<BikeRoute>>.broadcast();

  StreamSink<List<BikeRoute>> get _input => _routeStateController.sink;
  Stream<List<BikeRoute>> get output => _routeStateController.stream;

  final _routeEventController = StreamController<RouteBlocEvent>();
  Sink<RouteBlocEvent> get objectiveEventSync => _routeEventController.sink;

  RouteBloc() {
    _routeEventController.stream.listen((event) async {
      await _mapEventToState(event);
    });
  }

  Future<void> _mapEventToState(RouteBlocEvent event) async {
    List<BikeRoute> _returnList = [];
    switch (event.eventType) {
      case RouteEventType.RouteInitializeEvent:
        _returnList = await _getAllRoutes();
        _initialRoutes = _returnList.toList();
        break;
      case RouteEventType.RouteSearchEvent:
        if (_initialRoutes == null || _initialRoutes.isEmpty) break;
        var searchQuery = event.args['search_query'].toString().toLowerCase();
        _returnList = _initialRoutes.where((c) => c.name.toLowerCase().contains(searchQuery)).toList();
        break;
      case RouteEventType.RouteRateEvent:
        var route = _initialRoutes.where((c) => c.id == event.args['id']).first;
        if (route != null) route.rating = event.args['rating'];
        _returnList = _initialRoutes;
        break;
    }
    _input.add(_returnList);
  }

  Future<List<BikeRoute>> _getAllRoutes() async {
    var db = await DatabaseService().database;

    var routeRows = await db.query('route');
    var routes = List.generate(routeRows.length, (i) => BikeRoute.fromJson(routeRows[i]));
    return routes;
  }

  void dispose() {
    _routeEventController.close();
    _routeStateController.close();
  }
}
