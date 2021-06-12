import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class FilterDialog extends StatefulWidget {
  FilterDialog({Key key}) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  int difficulty = 0;
  var selectedRange = RangeValues(0, 500);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        actions: <Widget>[
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Anuleaza')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok')),
        ],
        content: Container(
          height: 200,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text('Dificultate'), flex: 2),
                  Expanded(
                      child: NumberPicker(
                          itemHeight: 48,
                          itemWidth: 64,
                          itemCount: 0,
                          minValue: 0,
                          maxValue: 5,
                          axis: Axis.horizontal,
                          value: difficulty,
                          onChanged: (value) {
                            setState(() {
                              difficulty = value;
                            });
                          }))
                ],
              ),
              Row(children: [
                Text('Distanta'),
                RangeSlider(
                    labels: RangeLabels(selectedRange.start.toString(), selectedRange.end.toString()),
                    values: selectedRange,
                    min: 0.0,
                    max: 500.0,
                    divisions: 10,
                    onChanged: (RangeValues newRange) {
                      setState(() {
                        selectedRange = newRange;
                      });
                    }),
              ])
            ],
          ),
        ),
        title: Text('Criterii de filtrare'),
      ),
    );
  }
}
