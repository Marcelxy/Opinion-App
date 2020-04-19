import 'package:flutter/material.dart';
import 'package:opinion_app/animations/fadeAnimation.dart';

class Clock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 40,
      top: 40,
      width: 80,
      height: 150,
      child: FadeAnimation(
        1.3,
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/clock.png'),
            ),
          ),
        ),
      ),
    );
  }
}