import 'package:flutter/material.dart';

class CreatorWidget extends StatefulWidget {
  final String creatorUsername;

  const CreatorWidget({Key key, this.creatorUsername}) : super(key: key);

  @override
  CreatorWidgetState createState() => CreatorWidgetState(creatorUsername: this.creatorUsername);
}

class CreatorWidgetState extends State<CreatorWidget> {
  String creatorUsername;

  CreatorWidgetState({this.creatorUsername});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
        child: Text(
          'Frage wurde gestellt von:\n' + widget.creatorUsername,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}