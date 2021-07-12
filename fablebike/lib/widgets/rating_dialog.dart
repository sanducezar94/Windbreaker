import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  RatingDialog({Key key}) : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _stars = 0;

  @override
  Widget build(BuildContext context) {
    Widget _buildStar(int starCount) {
      return InkWell(
        child: Icon(
          Icons.star,
          color: _stars >= starCount ? Theme.of(context).primaryColor : Colors.grey,
          size: 40,
        ),
        onTap: () {
          setState(() {
            _stars = starCount;
          });
        },
      );
    }

    return AlertDialog(
        actions: <Widget>[
          OutlinedButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 14),
                  primary: Theme.of(context).primaryColor,
                  side: BorderSide(style: BorderStyle.solid, color: Theme.of(context).primaryColor, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
              child: Text('Anuleaza')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_stars);
              },
              child: Text('Ok')),
        ],
        title: Center(child: Text('Acorda o nota')),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_buildStar(1), _buildStar(2), _buildStar(3), _buildStar(4), _buildStar(5)],
        ));
  }
}
