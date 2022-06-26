import "package:flutter/material.dart";

class SmallGridPainter extends CustomPainter {
  List<String> answers = ['없다', '왼쪽 위', '오른쪽 위', '왼쪽 아래', '오른쪽 아래'];
  final int _actualAnswer;
  final int _selectedAnswer;
  SmallGridPainter(this._actualAnswer, this._selectedAnswer);

  @override
  void paint(Canvas canvas, Size size) {
    double unitSize = 1 / 8 * size.width;
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;

    for (int i = 0; i < 7; i++) {
      Offset p1 = Offset((i + 1) * unitSize, unitSize);
      Offset p2 = Offset((i + 1) * unitSize, 7 * unitSize);
      Offset p3 = Offset(unitSize, (i + 1) * unitSize);
      Offset p4 = Offset(7 * unitSize, (i + 1) * unitSize);
      canvas.drawLine(p1, p2, paint);
      canvas.drawLine(p3, p4, paint);
    }
    if (_actualAnswer != 0) {
      Paint paintRight = Paint()
        ..color = Colors.green
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.0;

      int left = ((_actualAnswer - 1) % 2) * 3 + 1;
      int top = (_actualAnswer - 1) ~/ 2 * 3 + 1;
      int right = left + 3;
      int down = top + 3;

      Offset p1 = Offset(left * unitSize, top * unitSize);
      Offset p2 = Offset(right * unitSize, top * unitSize);
      Offset p3 = Offset(left * unitSize, down * unitSize);
      Offset p4 = Offset(right * unitSize, down * unitSize);

      canvas.drawLine(p1, p2, paintRight);
      canvas.drawLine(p1, p3, paintRight);
      canvas.drawLine(p2, p4, paintRight);
      canvas.drawLine(p3, p4, paintRight);
    }

    if (_selectedAnswer != _actualAnswer && _selectedAnswer != 0) {
      Paint paintWrong = Paint()
        ..color = Colors.red
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.0;

      int leftX = ((_selectedAnswer - 1) % 2) * 3 + 1;
      int topX = (_selectedAnswer - 1) ~/ 2 * 3 + 1;
      int rightX = leftX + 3;
      int downX = topX + 3;

      canvas.drawLine(Offset(leftX * unitSize, topX * unitSize),
          Offset(rightX * unitSize, downX * unitSize), paintWrong);
      canvas.drawLine(Offset(rightX * unitSize, topX * unitSize),
          Offset(leftX * unitSize, downX * unitSize), paintWrong);
    }
  }

  @override
  bool shouldRepaint(SmallGridPainter oldDelegate) {
    return false;
  }
}

class SmallGrid extends StatelessWidget {
  final size;
  final actualAnswer;
  final selectedAnswer;
  SmallGrid(this.size, this.actualAnswer, this.selectedAnswer);
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: SmallGridPainter(actualAnswer, selectedAnswer),
    );
  }
}
