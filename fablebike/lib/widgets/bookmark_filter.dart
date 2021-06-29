import 'package:fablebike/models/filters.dart';
import 'package:flutter/material.dart';

class BookmarkFilterDialog extends StatefulWidget {
  final BookmarkFilter filter;
  BookmarkFilterDialog({Key key, @required this.filter}) : super(key: key);

  @override
  _BookmarkFilterDialogState createState() => _BookmarkFilterDialogState();
}

class _BookmarkFilterDialogState extends State<BookmarkFilterDialog> {
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
            ],
          ),
        ),
        title: Text('Criterii de filtrare'),
      ),
    );
  }
}
