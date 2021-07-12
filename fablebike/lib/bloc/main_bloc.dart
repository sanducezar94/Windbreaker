import 'dart:async';

class MainBlocEvent {
  final String eventType;
  final Map<String, dynamic> args;

  MainBlocEvent({this.eventType, this.args});
}

class MainBloc {
  String _event;
  final _mainStateController = StreamController<String>.broadcast();

  StreamSink<String> get _input => _mainStateController.sink;
  Stream<String> get output => _mainStateController.stream;

  final _mainEventController = StreamController<String>();
  Sink<String> get objectiveEventSync => _mainEventController.sink;

  MainBloc() {
    _mainEventController.stream.listen((event) async {
      await _mapEventToState(event);
    });
  }

  Future<void> _mapEventToState(String event) async {
    _input.add(event);
  }

  void dispose() {
    _mainStateController.close();
    _mainEventController.close();
  }
}
