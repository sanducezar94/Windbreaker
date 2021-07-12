import 'package:flutter/material.dart';

class ConfirmDialog extends StatefulWidget {
  ConfirmDialog({Key key}) : super(key: key);

  @override
  _ConfirmDialogState createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        actions: <Widget>[
          OutlinedButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
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
                Navigator.of(context).pop(true);
              },
              child: Text('Confirma')),
        ],
        title: Center(child: Text('Goleste cache-ul')),
        content: Container(
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(
                  flex: 1,
                ),
                Expanded(
                    child: RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                          text: 'Datele precum obiectivele salvate, preferintele si cautarile anterioare vor fi sterse permanent!',
                          style: Theme.of(context).textTheme.headline3),
                      maxLines: 5,
                    ),
                    flex: 10),
                Spacer(
                  flex: 1,
                )
              ],
            )));
  }
}
