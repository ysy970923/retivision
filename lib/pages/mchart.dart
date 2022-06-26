import 'package:flutter/material.dart';
import 'package:retivision_v2/components/test_template.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TestMChartPage extends StatelessWidget {
  const TestMChartPage({Key? key}) : super(key: key);
  static const routeName = 'm-chart-page';

  @override
  Widget build(BuildContext context) {
    return const TestTemplate(
      testName: 'mchart',
    );
  }
}

class TestMChart extends StatefulWidget {
  final int distanceLevel;
  final Function nextPage;
  final stt.SpeechToText speech;
  const TestMChart({
    Key? key,
    required this.distanceLevel,
    required this.nextPage,
    required this.speech,
  }) : super(key: key);

  @override
  _TestMChartState createState() => _TestMChartState();
}

class _TestMChartState extends State<TestMChart> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomPaint(
          size: Size(200, 200),
          painter: MChartPainter(),
        )
      ],
    );
  }
}

class MChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;
    Offset start = Offset(0, 50);
    Offset end = Offset(100, 50);
    for (int i = 0; i < 20; i++) {
      Offset? p = Offset.lerp(start, end, i / 20);
      canvas.drawCircle(p!, 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
