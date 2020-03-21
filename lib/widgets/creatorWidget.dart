import 'package:flutter/material.dart';

class CreatorWidget extends StatefulWidget {
  final String creator;

  const CreatorWidget({Key key, this.creator}) : super(key: key);

  @override
  CreatorWidgetState createState() => CreatorWidgetState(creator: this.creator);
}

class CreatorWidgetState extends State<CreatorWidget> {
  String creator;

  CreatorWidgetState({this.creator});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
        child: Text(
          'Frage wurde gestellt von:\n' + widget.creator,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}