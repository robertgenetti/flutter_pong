import 'package:flutter/material.dart';

class Ball extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double diam = 50;

    return Container(
      width: diam,
      height: diam,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.amber[400]),
    );
  }
}
