import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  RatingDialog({Key key}) : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _stars = 0;

  Widget _buildStar(int starCount) {
    return InkWell(
      child: Icon(Icons.star,
          color: _stars >= starCount ? Colors.orange : Colors.grey),
      onTap: () {
        setState(() {
          _stars = starCount;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        actions: <Widget>[
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
          children: [
            _buildStar(1),
            _buildStar(2),
            _buildStar(3),
            _buildStar(4),
            _buildStar(5)
          ],
        ));
  }
}
