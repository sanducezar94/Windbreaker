import 'package:fablebike/models/route.dart';
import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final RouteFilter filter;
  FilterDialog({Key key, @required this.filter}) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        actions: <Widget>[
          OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Anuleaza')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(widget.filter);
              },
              child: Text('Ok')),
        ],
        content: Container(
          height: 200,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text('Dificultate'), flex: 1),
                  Expanded(
                    flex: 2,
                    child: RangeSlider(
                        labels: RangeLabels(widget.filter.difficulty.start.toString(), widget.filter.difficulty.end.toString()),
                        values: widget.filter.difficulty,
                        min: 0.0,
                        max: 5.0,
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
                  Expanded(
                    flex: 2,
                    child: RangeSlider(
                        labels: RangeLabels(widget.filter.rating.start.toString(), widget.filter.rating.end.toString()),
                        values: widget.filter.rating,
                        min: 0.0,
                        max: 5.0,
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
                  Expanded(
                    flex: 2,
                    child: RangeSlider(
                        labels: RangeLabels(widget.filter.distance.start.toString(), widget.filter.distance.end.toString()),
                        values: widget.filter.distance,
                        min: 0.0,
                        max: 500.0,
                        divisions: 10,
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
                  Expanded(
                    flex: 2,
                    child: RangeSlider(
                        labels: RangeLabels(widget.filter.poiCount.start.toString(), widget.filter.poiCount.end.toString()),
                        values: widget.filter.poiCount,
                        min: 0.0,
                        max: 30.0,
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
        title: Text('Criterii de filtrare'),
      ),
    );
  }
}
