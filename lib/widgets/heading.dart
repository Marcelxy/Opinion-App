import 'package:flutter/material.dart';
import 'package:opinion_app/util/colors.dart';
import 'package:opinion_app/animations/fadeAnimation.dart';

class Heading extends StatefulWidget {
  final String heading;

  const Heading({Key key, this.heading}) : super(key: key);

  @override
  HeadingState createState() => HeadingState(heading: this.heading);
}

class HeadingState extends State<Heading> {
  String heading;

  HeadingState({this.heading});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: FadeAnimation(
        1.6,
        Container(
          margin: EdgeInsets.only(top: 70),
          child: Center(
            child: Text(widget.heading,
                style: TextStyle(color: textOnSecondaryWhite, fontSize: 40, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}