import 'package:flutter/material.dart';
import 'package:opinion_app/animations/fadeAnimation.dart';

class Light2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 140,
      width: 80,
      height: 150,
      child: FadeAnimation(
        1,
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/light2.png'),
            ),
          ),
        ),
      ),
    );
  }
}