import 'package:flutter/material.dart';
import 'package:opinion_app/animations/fadeAnimation.dart';

class Light1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 30,
      width: 80,
      height: 200,
      child: FadeAnimation(
        1,
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/light1.png'),
            ),
          ),
        ),
      ),
    );
  }
}