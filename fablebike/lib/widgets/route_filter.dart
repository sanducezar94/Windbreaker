import 'package:fablebike/models/filters.dart';
import 'package:fablebike/models/route.dart';
import 'package:flutter/material.dart';

class RouteFilterDialog extends StatefulWidget {
  final RouteFilter filter;
  RouteFilterDialog({Key key, @required this.filter}) : super(key: key);

  @override
  _RouteFilterDialogState createState() => _RouteFilterDialogState();
}

class _RouteFilterDialogState extends State<RouteFilterDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        actions: <Widget>[
          Padding(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(widget.filter);
                      },
                      child: Text('Aplica Filtre')),
                  flex: 1,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 15),
          )
        ],
        content: Container(
          height: 275,
          width: 500,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text('Dificultate'), flex: 1),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: RangeSlider(
                        labels: RangeLabels(widget.filter.difficulty.start.toString(), widget.filter.difficulty.end.toString()),
                        values: widget.filter.difficulty,
                        min: 0.0,
                        max: 5.0,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Color.fromRGBO(98, 98, 98, 1),
                        divisions: 5,
                        onChanged: (RangeValues newRange) {
                          setState(() {
                            widget.filter.difficulty = newRange;
                          });
                        }),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Rating'), flex: 1),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: RangeSlider(
                        labels: RangeLabels(widget.filter.rating.start.toString(), widget.filter.rating.end.toString()),
                        values: widget.filter.rating,
                        min: 0.0,
                        max: 5.0,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Color.fromRGBO(98, 98, 98, 1),
                        divisions: 5,
                        onChanged: (RangeValues newRange) {
                          setState(() {
                            widget.filter.rating = newRange;
                          });
                        }),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Distanta'), flex: 1),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: RangeSlider(
                        labels: RangeLabels(widget.filter.distance.start.toString(), widget.filter.distance.end.toString()),
                        values: widget.filter.distance,
                        min: 0.0,
                        max: 500.0,
                        divisions: 10,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Color.fromRGBO(98, 98, 98, 1),
                        onChanged: (RangeValues newRange) {
                          setState(() {
                            widget.filter.distance = newRange;
                          });
                        }),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Obiective'), flex: 1),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: RangeSlider(
                        labels: RangeLabels(widget.filter.poiCount.start.toString(), widget.filter.poiCount.end.toString()),
                        values: widget.filter.poiCount,
                        min: 0.0,
                        max: 30.0,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Color.fromRGBO(98, 98, 98, 1),
                        divisions: 15,
                        onChanged: (RangeValues newRange) {
                          setState(() {
                            widget.filter.poiCount = newRange;
                          });
                        }),
                  )
                ],
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text('Filtrare'),
              flex: 10,
            ),
            Expanded(
              child: Icon(Icons.close),
              flex: 2,
            )
          ],
        ),
      ),
    );
  }
}
