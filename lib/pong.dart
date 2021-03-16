import 'dart:math';

import 'package:flutter/material.dart';

import 'ball.dart';
import 'bat.dart';

enum Direction { UP, RIGHT, DOWN, LEFT }

class Pong extends StatefulWidget {
  @override
  _PongState createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  double width;
  double height;
  double posX = 0;
  double posY = 0;
  double batWidth = 0;
  double batHeight = 0;
  double batPosition = 175;
  Direction hDir = Direction.RIGHT;
  Direction vDir = Direction.DOWN;
  double increment = 3;
  double ranX = 1.0;
  double ranY = 1.0;
  int score = 0;

  // animation handlers
  Animation<double> animation;
  AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // dynamic variables go here
      width = constraints.maxWidth;
      height = constraints.maxHeight;

      // update class vars
      batWidth = width / 5;
      batHeight = height / 20;
      return Stack(
        children: [
          Positioned(
            child: Text('Score: ' + score.toString()),
            top: 0,
            right: 25,
          ),
          Positioned(
            child: Ball(),
            top: posY,
            left: posX,
          ),
          Positioned(
            child: GestureDetector(
              onHorizontalDragUpdate: (DragUpdateDetails update) =>
                  moveBat(update),
              child: Bat(
                width: batWidth,
                height: batHeight,
              ),
            ),
            bottom: 5,
            left: batPosition,
          )
        ],
      );
    });
  }

  @override
  void initState() {
    posX = 0;
    posY = 0;
    controller = AnimationController(
        duration: const Duration(minutes: 10000), vsync: this);
    // setup animation then listen
    animation = Tween<double>(begin: 0, end: 100).animate(controller);
    animation.addListener(() {
      _safeSetState(() {
        (hDir == Direction.RIGHT)
            ? posX += ((increment * ranX).round())
            : posX -= ((increment * ranX).round());
        (vDir == Direction.DOWN)
            ? posY += ((increment * ranY).round())
            : posY -= ((increment * ranY).round());
      });
      checkBorders();
    });
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void checkBorders() {
    if (posX <= 0 && hDir == Direction.LEFT) {
      this.hDir = Direction.RIGHT;
      this.ranX = randomNum();
    }
    if (posX >= width - 50 && hDir == Direction.RIGHT) {
      this.hDir = Direction.LEFT;
      this.ranX = randomNum();
    }
    if (posY <= 0 && vDir == Direction.UP) {
      this.vDir = Direction.DOWN;
      this.ranY = randomNum();
    }
    if (posY >= (height - 58 - batHeight) && vDir == Direction.DOWN) {
      //check if the bat is here, otherwise loose
      if (posX >= (batPosition - 33) && posX <= (batPosition + batWidth + 33)) {
        vDir = Direction.UP;
        this.ranY = randomNum();
        increment *= 1.02;
        _addScore();
      } else {
        // this.isGameOver = true;
        controller.stop();
        showMessage(context);
      }
    }
  }

  moveBat(DragUpdateDetails update) {
    _safeSetState(() {
      if (batPosition < 0) {
        this.batPosition = 0;
      } else if (batPosition > width - batWidth) {
        this.batPosition = width - batWidth;
      } else {
        this.batPosition += update.delta.dx;
      }
    });
  }

  void _safeSetState(Function function) {
    if (mounted && controller.isAnimating) {
      setState(() {
        function();
      });
    }
  }

  double randomNum() {
    var ran = Random();
    return (ran.nextInt(101) + 50) / 100;
  }

  void _addScore() {
    this.score += ((ranX + ranY) * increment).toInt();
  }

  void showMessage(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: Text('Would you like to play again?'),
            actions: [
              FlatButton(
                  onPressed: () {
                    setState(() {
                      posX = 0;
                      posY = 0;
                      score = 0;
                    });
                    Navigator.of(context).pop();
                    controller.repeat();
                  },
                  child: Text('Yes')),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    dispose();
                  },
                  child: Text('No'))
            ],
          );
        });
  }
}
