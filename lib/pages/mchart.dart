import 'package:flutter/material.dart';
import 'package:retivision_v2/components/test_template.dart';
import 'package:retivision_v2/models/result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../components/camera_box.dart';
import '../widgets/platform_alert_dialog.dart';
import 'dart:math';

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

const int nDots = 60;

class _TestMChartState extends State<TestMChart> {
  List<int> levels = [1];
  List<int> answers = [Random().nextInt(nDots - 10) + 5];
  List<double?> selecteds = [null];
  late Result result;

  Future<void> nextPage() async {
    if (selecteds.last == null) {
      await PlatformAlertDialog(
        title: "정답이 선택되지 않았습니다",
        content: "정답을 선택해주셔야 넘어갈 수 있습니다",
        defaultActionText: "네",
      ).show(context);
    } else if (levels.last == 3) {
      result.visionTestResult = levels.last;
      result.testLevel = 2;
      widget.nextPage();
    } else {
      setState(() {
        levels.add(levels.last + 1);
        answers.add(Random().nextInt(nDots - 10) + 5);
        selecteds.add(null);
      });
    }
  }

  void select(TapDownDetails details, double gridSize) {
    print(details.localPosition);
    setState(() {
      selecteds.last = details.localPosition.dx / gridSize * nDots;
      print(selecteds.last);
      // selecteds.last = 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double gridSize = min(width, height) * 0.9;
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CameraBox(
                    distanceLevel: widget.distanceLevel,
                  ),
                ),
              ),
              Expanded(
                child: (levels.length == 1)
                    ? Container()
                    : TextButton.icon(
                        icon: const Icon(
                          Icons.arrow_left,
                          size: 50,
                        ),
                        label: const Text(
                          '이전',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => setState(() {
                          // levels.removeLast();
                          // selecteds.removeLast();
                          // answers.removeLast();
                        }),
                      ),
              )
            ],
          ),
        ),
        Expanded(
            child: Center(
          child: GestureDetector(
            onTapDown: (details) => select(details, gridSize*0.9),
            child: MChart(
              selected: selecteds.last,
              dDot: answers.last,
              size: gridSize * 0.9,
            ),
          ),
        )),
        Expanded(
          child: Column(
            children: [
              Expanded(child: Container()),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.arrow_right,
                    size: 50,
                  ),
                  label: Text(
                    levels.length == 3 ? '완료' : '다음',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => nextPage(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MChart extends StatelessWidget {
  final double? selected;
  final int? dDot;
  final double size;
  const MChart({
    Key? key,
    required this.selected,
    required this.dDot,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Offset? selectedOffset;
    Offset start = Offset(0, size * 0.5);
    Offset end = Offset(size, size * 0.5);

    if (selected != null) {
      selectedOffset = Offset.lerp(start, end, selected! / nDots);
      print(size);
    }
    return Stack(
      children: [
        CustomPaint(
          size: Size(size, size * 0.5),
          painter: MChartPainter(dDot: dDot),
        ),
        if (selected != null)
          Positioned(
            top: selectedOffset!.dy,
            left: selectedOffset!.dx,
            child: Container(
              decoration: BoxDecoration(border: Border.all(width: 10)),
              height: 50,
              width: 50,
            ),
          )
      ],
    );
  }
}

class MChartPainter extends CustomPainter {
  int? dDot;

  MChartPainter({this.dDot});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;
    Offset start = Offset(0, size.height * 0.5);
    Offset end = Offset(size.width, size.height * 0.5);
    for (int i = 0; i < nDots; i++) {
      Offset? p = Offset.lerp(start, end, i / nDots);
      if (dDot != null) {
        if ((i - dDot!).abs() <= 3) {
          p = p!.translate(0, 21 - 7 * (i - dDot!).abs().toDouble());
        }
      }
      canvas.drawCircle(p!, 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
