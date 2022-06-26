import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retivision_v2/pages/note.dart';
import 'package:string_similarity/string_similarity.dart';

// import '../stt.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../components/test_template.dart';
import '../tts.dart';
import '../models/result.dart';
import 'package:retivision_v2/global.dart';

class TestReadingPage extends StatelessWidget {
  const TestReadingPage({Key? key}) : super(key: key);
  static const routeName = 'test-reading-page';

  @override
  Widget build(BuildContext context) {
    return const TestTemplate(
      testName: 'reading',
    );
  }
}

class TestReading extends StatefulWidget {
  final int distanceLevel;
  final Function nextPage;
  final stt.SpeechToText speech;

  const TestReading({
    Key? key,
    required this.distanceLevel,
    required this.nextPage,
    required this.speech,
  }) : super(key: key);
  @override
  _ReadTestPageState createState() => _ReadTestPageState();
}

class _ReadTestPageState extends State<TestReading> {
  TextEditingController currentController = TextEditingController();
  DateTime? startTime;
  double duration = 0;
  List<String> readText = [
    '누구든 새로운 길을 향해 나아가기 위해서는 스스로의 힘으로 개척해야만 한다. 자신이 올바른 방향으로 나아가는지 끊임없이 확인해야 한다.',
    '소설을 쓰는 과정에서 느낀 점을 정리한 것이지만, 다른 모든 종류의 글쓰기에도 적용할 수 있는 원칙을 말하고 있다는 점에서 글쓰기를 가르치는 이들이나 글쓰기를 깊게 배우려는 이들은 한번 읽어두는 게 좋다.\n한번 읽고 쌓아두는 책이 아니라 곁에 두고 자주 봐야 하는 책이라는 느낌이 든다.',
  ];
  late List<String> readWords;
  double _confidence = 1.0;
  String _text = '';

  @override
  void initState() {
    super.initState();
    widget.speech.errorListener = (val) => _listen();
  }

  void _listen() {
    if (!widget.speech.isAvailable) {
      return;
    }
    if (!widget.speech.isListening) {
      startTime ??= DateTime.now();
      widget.speech
          .listen(
            onResult: (val) => setState(() {
              currentController.text = _text + val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence;
              }
              if (val.finalResult) {
                _text += val.recognizedWords + ' ';
                currentController.text = _text;
                if (startTime != null) {
                  print("new listen");
                  widget.speech.stop().then((value) => _listen());
                }
              }
            }),
          )
          .then((value) => setState(() {}));
    } else {
      duration = DateTime.now().difference(startTime!).inMilliseconds / 1000;
      startTime = null;
      widget.speech.stop().then((value) => setState(() {}));
    }
  }

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
      child: Row(
        children: [
          IconButton(
            iconSize: 120,
            icon: Icon(
              Icons.mic,
              color: (widget.speech.isListening ? Colors.black : Colors.grey),
            ),
            onPressed: () {
              if (startTime == null) {
                _text = '';
                currentController.text = '';
              }
              _listen();
            },
          ),
          Expanded(
            child: TextField(
              controller: currentController,
              maxLines: 5,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: '위 글을 따라 읽어주세요',
                hintStyle: const TextStyle(fontSize: 30),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(width: 10),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = Provider.of<Result>(context);
    readWords = readText[result.testLevel! - 1].split(' ');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retivision'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text('아래 문장을 따라 읽어주세요.'),
            const Text('다 읽으시면 마이크 버튼을 다시 눌러주세요.'),
            const SizedBox(height: 20),
            Container(
              width: 1000,
              decoration: BoxDecoration(border: Border.all()),
              padding: const EdgeInsets.all(15),
              child: Text(
                readText[result.testLevel! - 1],
                style: const TextStyle(
                    fontSize: 30, height: 1.2, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(),
            ElevatedButton(
              onPressed: () {
                result.readDuration = duration.toString();
                widget.nextPage();
              },
              child: const Text("확인"),
            ),
          ],
        ),
      ),
    );
  }
}
