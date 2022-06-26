import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retivision_v2/components/test_template.dart';
import '../components/camera_box.dart';
import '../components/test_template.dart';
import '../widgets/platform_alert_dialog.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/result.dart';

class TestLandoltPage extends StatelessWidget {
  const TestLandoltPage({Key? key}) : super(key: key);
  static const routeName = 'test-landolt-page';

  @override
  Widget build(BuildContext context) {
    return const TestTemplate(
      testName: 'landolt',
    );
  }
}

class TestLandoltRingPainter extends CustomPainter {
  TestLandoltRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = size.width / 6;
    double radius = strokeWidth * 2.5;
    final paint = Paint()
      ..color = Color.fromARGB((255 * size.width) ~/ 250, 0, 0, 0)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill; //important set stroke style

    final path = Path()
      ..moveTo(size.width / 2 + radius + strokeWidth / 2,
          size.height / 2 - strokeWidth / 2)
      ..arcToPoint(
          Offset(size.width / 2 + radius + strokeWidth / 2,
              size.height / 2 + strokeWidth / 2),
          radius: Radius.circular(radius + strokeWidth / 2),
          largeArc: true,
          clockwise: false)
      ..lineTo(size.width / 2 + radius - strokeWidth / 2,
          size.height / 2 + strokeWidth / 2)
      ..arcToPoint(
          Offset(size.width / 2 + radius - strokeWidth / 2,
              size.height / 2 - strokeWidth / 2),
          radius: Radius.circular(radius - strokeWidth / 2),
          largeArc: true);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TestLandolt extends StatefulWidget {
  final int distanceLevel;
  final Function nextPage;
  final stt.SpeechToText speech;

  const TestLandolt({
    Key? key,
    required this.distanceLevel,
    required this.nextPage,
    required this.speech,
  }) : super(key: key);
  @override
  _TestLandoltState createState() => _TestLandoltState();
}

class _TestLandoltState extends State<TestLandolt> {
  final answerOptions = ['오른쪽', '아래쪽', '왼쪽', '위쪽', '안 보여요', '다음'];
  int nSameLevel = 0;
  List<int> levels = [1];
  List<int> answers = [Random().nextInt(3)];
  List<int?> selecteds = [null];
  late Result result;

  @override
  void initState() {
    super.initState();
    widget.speech.errorListener = (val) => setState(() {});
  }

  void _listen() {
    if (!widget.speech.isAvailable) {
      return;
    }
    if (!widget.speech.isListening) {
      widget.speech
          .listen(
            partialResults: false,
            listenFor: const Duration(seconds: 5),
            onResult: (val) => setState(() {
              int selectedIndex =
                  val.recognizedWords.bestMatch(answerOptions).bestMatchIndex;
              if (selectedIndex == 5) {
                nextPage();
              } else {
                selecteds.last = selectedIndex;
              }
            }),
          )
          .then((value) => setState(() {}));
    } else {
      widget.speech.stop().then((value) => setState(() {}));
    }
  }

  Widget _buildAnswerBox(int answerType, double width) {
    bool _selected = (answerType == selecteds.last);
    return GestureDetector(
      onTap: () => setState(() {
        selecteds.last = _selected ? null : answerType;
      }),
      child: Container(
        width: width,
        alignment: Alignment.center,
        child: Text(
          answerOptions[answerType],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _selected ? Colors.lightBlue : Colors.grey[800],
          ),
        ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            width: 5,
            color: _selected ? Colors.lightBlue : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> nextPage() async {
    if (selecteds.last == null) {
      await PlatformAlertDialog(
        title: "정답이 선택되지 않았습니다",
        content: "정답을 선택해주셔야 넘어갈 수 있습니다",
        defaultActionText: "네",
      ).show(context);
    } else if (selecteds.last == answers.last) {
      if (levels.last == 5) {
        result.visionTestResult = levels.last;
        result.testLevel = 2;
        widget.nextPage();
      }
      // 정답을 맞출 경우 level 올려서 다음 문제
      else {
        setState(() {
          levels.add(levels.last + 1);
          answers.add(Random().nextInt(3));
          selecteds.add(null);
          nSameLevel = 0;
        });
      }
    } else {
      nSameLevel++;
      // 2번 틀리면 level 기록, 다음 test, 2번까지 반복
      if (nSameLevel < 2) {
        setState(() {
          levels.add(levels.last);
          answers.add(Random().nextInt(3));
          selecteds.add(null);
        });
      } else {
        result.visionTestResult = levels.last;
        result.testLevel = levels.last < 3 ? 1 : 2;
        widget.nextPage();
      }
    }
  }

  Widget _buildTestLandoltRing(double width, int quarterTurns) {
    return Container(
      width: width,
      height: width,
      padding: const EdgeInsets.all(10),
      child: RotatedBox(
        quarterTurns: quarterTurns,
        child: CustomPaint(
          size: Size(width, width),
          painter: TestLandoltRingPainter(
              // animation.value,
              ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    result = Provider.of<Result>(context);
    double answerBoxWidth = MediaQuery.of(context).size.height * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retivision'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  // flex: 2,
                  child: IconButton(
                    iconSize: 120,
                    icon: Icon(
                      Icons.mic,
                      color: widget.speech.isListening
                          ? Colors.black
                          : Colors.grey,
                    ),
                    onPressed: _listen,
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
                            levels.removeLast();
                            selecteds.removeLast();
                            answers.removeLast();
                          }),
                        ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Expanded(
                  flex: 1,
                  child: Center(child: Text('고리의 빈틈 방향을 찾아주세요.')),
                ),
                Expanded(
                  flex: 8,
                  child: Center(
                    child:
                        _buildTestLandoltRing(250 / levels.last, answers.last),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAnswerBox(0, answerBoxWidth),
                      _buildAnswerBox(1, answerBoxWidth),
                      _buildAnswerBox(2, answerBoxWidth),
                      _buildAnswerBox(3, answerBoxWidth),
                      _buildAnswerBox(4, answerBoxWidth),
                    ],
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(
                      Icons.arrow_right,
                      size: 50,
                    ),
                    label: const Text(
                      '다음',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: nextPage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
