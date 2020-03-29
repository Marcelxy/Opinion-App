import 'package:flutter/material.dart';

class Creator extends StatefulWidget {
  final String creatorUsername;

  const Creator({Key key, this.creatorUsername}) : super(key: key);

  @override
  CreatorState createState() => CreatorState(creatorUsername: this.creatorUsername);
}

class CreatorState extends State<Creator> {
  String creatorUsername;

  CreatorState({this.creatorUsername});

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