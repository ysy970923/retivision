import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:core';

double sigmoid(x) {
  return (1 - exp(-x)) / (1 + exp(-x));
}

Offset update(Offset point, Offset? dPoint, num dLevel, num unitSize) {
  if (dPoint == null) return point;

  final dist = (point - dPoint).distance;
  if (dist == 0) return point;
  final distFromBorder = min(
    min(point.dx - unitSize, unitSize * 21 - point.dx),
    min(point.dy - unitSize, unitSize * 21 - point.dy),
  ).abs();
  Offset changedPoint;
  if (distFromBorder < unitSize) {
    changedPoint = Offset.lerp(
      dPoint,
      point,
      sigmoid(dist / (dLevel * distFromBorder + 1)),
    )!;
  } else {
    changedPoint = Offset.lerp(
      dPoint,
      point,
      sigmoid(dist / (dLevel * unitSize)),
    )!;
  }
  return changedPoint;
}

class DistortedGridPainter extends CustomPainter {
  Offset? _dPoint;
  double _dLevel;
  double midRadius;

  DistortedGridPainter(this._dPoint, this._dLevel, this.midRadius);
  int nDotsInLine = 400;

  @override
  void paint(Canvas canvas, Size size) {
    double unitSize = 1 / 22 * size.width;
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    var borderPoints = List.generate(
        4, (i) => List.filled(21, const Offset(0, 0), growable: false),
        growable: false);
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 21; j++) {
        if (i == 0) {
          borderPoints[i][j] = Offset(unitSize, (j + 1) * unitSize);
        } else if (i == 1) {
          borderPoints[i][j] = Offset((j + 1) * unitSize, unitSize);
        } else if (i == 2) {
          borderPoints[i][j] = Offset((j + 1) * unitSize, 21 * unitSize);
        } else {
          borderPoints[i][j] = Offset(21 * unitSize, (j + 1) * unitSize);
        }
      }
    }

    // make distorted dots inside the inBorder
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 21; j++) {
        for (int k = 0; k <= nDotsInLine; k++) {
          Offset p = Offset.lerp(
            borderPoints[i][j],
            borderPoints[3 - i][j],
            k / nDotsInLine,
          )!;
          p = update(p, _dPoint, _dLevel, unitSize);
          canvas.drawCircle(p, 2, paint);
        }
      }
    }
    // make border line
    final middle = Offset.lerp(borderPoints[0][10], borderPoints[3][10], 0.5)!;
    canvas.drawCircle(middle, midRadius, paint);
  }

  @override
  bool shouldRepaint(DistortedGridPainter oldDelegate) {
    return oldDelegate.midRadius != midRadius;
  }
}

class Grid extends StatefulWidget {
  final int selected;
  final double size;
  final Offset? dPoint;
  final double dLevel;
  const Grid({
    Key? key,
    required this.selected,
    required this.size,
    required this.dPoint,
    required this.dLevel,
  }) : super(key: key);
  @override
  _GridState createState() => _GridState();
}

class _GridState extends State<Grid> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    animation = Tween<double>(begin: 10.0, end: 15.0).animate(controller);
    controller.addListener(() {
      setState(() {});
    });
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(widget.size, widget.size),
          painter: DistortedGridPainter(
            widget.dPoint == null
                ? null
                : widget.dPoint!.scale(widget.size, widget.size),
            widget.dLevel,
            animation.value,
          ),
        ),
        if (widget.selected != 0)
          Positioned(
            top: (widget.size / 2) * ((widget.selected - 1) ~/ 2),
            left: (widget.size / 2) * ((widget.selected - 1) % 2),
            child: Opacity(
              opacity: 0.7,
              child: Container(
                height: widget.size / 2,
                width: widget.size / 2,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
