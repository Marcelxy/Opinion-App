import 'package:flutter/material.dart';

class PercentProgressBarWidget extends StatefulWidget {
  final double percentValue;
  final double percentTextValue;

  const PercentProgressBarWidget({Key key, this.percentValue, this.percentTextValue}) : super(key: key);

  @override
  PercentProgressBarWidgetState createState() => PercentProgressBarWidgetState(percentValue: this.percentValue, percentTextValue: this.percentTextValue);
}

class PercentProgressBarWidgetState extends State<PercentProgressBarWidget> {
  double percentValue;
  double percentTextValue;

  PercentProgressBarWidgetState({this.percentValue, this.percentTextValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      child: Stack(
        children: <Widget>[
          SizedBox(
            height: 14,
            child: LinearProgressIndicator(
              value: widget.percentValue,
              backgroundColor: Colors.transparent.withOpacity(0.25),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          Align(
              child: Text(widget.percentTextValue.toStringAsFixed(1) + '%',
                  style: TextStyle(fontSize: 14.0, height: 0.85, fontWeight: FontWeight.w600)),
              alignment: Alignment.center,),
        ],
      ),
    );
  }
}