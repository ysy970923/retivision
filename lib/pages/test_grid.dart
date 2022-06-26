import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retivision_v2/components/camera_box.dart';
import 'package:retivision_v2/global.dart';
import 'package:retivision_v2/pages/test_hue.dart';
import 'package:retivision_v2/components/test_template.dart';
import '../components/grid.dart';
import '/widgets/platform_alert_dialog.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/result.dart';

class TestGridPage extends StatelessWidget {
  const TestGridPage({Key? key}) : super(key: key);
  static const routeName = 'test-grid-page';

  @override
  Widget build(BuildContext context) {
    return const TestTemplate(
      testName: 'grid',
    );
  }
}

class TestGrid extends StatefulWidget {
  final int distanceLevel;
  final Function nextPage;
  final stt.SpeechToText speech;
  const TestGrid({
    Key? key,
    required this.distanceLevel,
    required this.nextPage,
    required this.speech,
  }) : super(key: key);
  @override
  _TestGridState createState() => _TestGridState();
}

class _TestGridState extends State<TestGrid> {
  bool useCamera = true;
  final int _totalGridNum = 2;
  int _gridNum = 0;
  final List<bool> _actualDistorted = [];
  final List<int> _selectDistorted = [];
  late List<Offset?> _dPoints;
  late List<double> _dLevels;
  // late TTS tts;
  late Result result;
  List<String> answerOptions = [
    '없음',
    '왼쪽 위',
    '오른쪽 위',
    '왼쪽 아래',
    '오른쪽 아래',
    '다음',
    '완료'
  ];
  bool firstLoad = true;

  @override
  void initState() {
    super.initState();
    _dPoints = [];
    _dLevels = [];
    Random random = Random();
    for (int i = 0; i < _totalGridNum; i++) {
      final _distorted = step(random.nextDouble() - 0.7);
      _actualDistorted.add(_distorted);
      _selectDistorted.add(0);
    }
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
              if (selectedIndex == 5 || selectedIndex == 6) {
                nextPage();
              } else {
                _selectDistorted[_gridNum] = selectedIndex;
              }
            }),
          )
          .then((value) => setState(() {}));
    } else {
      widget.speech.stop().then((value) => setState(() {}));
    }
  }

  bool step(double x) {
    if (x > 0) {
      return true;
    } else {
      return false;
    }
  }

  void _makeDPoints(double gridSize) {
    var _random = Random();
    for (int i = 0; i < _totalGridNum; i++) {
      Offset? dPoint;
      double dLevel = 0;
      double x, y;
      if (_actualDistorted[i]) {
        x = [0.25, 0.75][_random.nextInt(2)];
        y = [0.25, 0.75][_random.nextInt(2)];
        dPoint = Offset(x, y);
        dLevel = (_random.nextInt(10) + 5) / 15; // 0.33 ~ 1
      }
      _dPoints.add(dPoint);
      _dLevels.add(dLevel);
    }
    result.actualDistorted = _actualDistorted;
    result.dPoints = _dPoints;
    result.dLevels = _dLevels;
  }

  num argmax(List<dynamic> list) {
    dynamic maxNum = list[0];
    num maxIndex = 0;
    for (int i = 1; i < list.length; i++) {
      if (list[i] > maxNum) {
        maxNum = list[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  Widget _buildAnswerBox(int answerType, double width) {
    bool _selected = (answerType == _selectDistorted[_gridNum]);
    return GestureDetector(
      onTap: () => setState(() {
        _selectDistorted[_gridNum] = _selected ? 0 : answerType;
      }),
      child: Container(
        width: width,
        alignment: Alignment.center,
        child: Text(
          answerOptions[answerType],
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _selected ? Colors.lightBlue : Colors.grey[800]),
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
    if (_gridNum != _totalGridNum - 1) {
      setState(() {
        _gridNum++;
      });
    } else {
      result.selectDistorted = _selectDistorted;
      widget.nextPage();
    }
  }

  void select(TapDownDetails details, double gridSize) {
    double x = details.localPosition.dx;
    double y = details.localPosition.dy;
    int newSelected = (x ~/ (gridSize / 2)) + (y ~/ (gridSize / 2)) * 2 + 1;
    if (_selectDistorted[_gridNum] == newSelected) {
      newSelected = 0;
    }
    setState(() {
      _selectDistorted[_gridNum] = newSelected;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double gridSize = min(width, height) * 0.9;
    double answerBoxWidth = gridSize * 0.25;

    if (firstLoad) {
      result = Provider.of<Result>(context);
      _makeDPoints(gridSize);
      firstLoad = false;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CameraBox(distanceLevel: widget.distanceLevel),
                ),
              ),
              Expanded(
                // flex: 2,
                child: IconButton(
                  iconSize: 120,
                  icon: Icon(
                    Icons.mic,
                    color:
                        widget.speech.isListening ? Colors.black : Colors.grey,
                  ),
                  onPressed: _listen,
                ),
              ),
              Expanded(
                child: (_gridNum == 0)
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
                          _gridNum--;
                        }),
                      ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            const Expanded(
              flex: 1,
              child: Center(child: Text('격자에 왜곡이 보이시나요?')),
            ),
            Expanded(
              flex: 8,
              child: Center(
                child: GestureDetector(
                  onTapDown: (details) => select(details, gridSize * 0.9),
                  child: Grid(
                    selected: _selectDistorted[_gridNum],
                    size: gridSize * 0.9,
                    dPoint: _dPoints[_gridNum],
                    dLevel: _dLevels[_gridNum],
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(height: 20),
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
                  label: Text(
                    (_gridNum != _totalGridNum - 1) ? '다음' : '완료',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: nextPage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
