import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedButtonWidget extends StatelessWidget {
  final Widget child;
  final double width;
  final BorderRadius borderRadius;
  final Function onpressed;

  RoundedButtonWidget({this.child, this.width, this.onpressed, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 8.0)],
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            stops: [0, 1],
            colors: [
              Theme.of(context).primaryColor,
              Color.fromRGBO(157, 207, 78, 1),
            ],
          ),
          color: Colors.deepPurple.shade300,
          borderRadius: borderRadius == null ? BorderRadius.circular(12) : borderRadius,
        ),
        child: ElevatedButton(
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(Size(width, 50)),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            // elevation: MaterialStateProperty.all(3),
            shadowColor: MaterialStateProperty.all(Colors.transparent),
          ),
          onPressed: () {
            onpressed();
          },
          child: Padding(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 8,
              ),
              child: child),
        ),
      ),
    );
  }
}
