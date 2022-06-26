import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/platform_alert_dialog.dart';

import '../tts.dart';
import '../models/result.dart';
import '../models/auth.dart';
import 'package:retivision_v2/global.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TextFieldData {
  final int key;
  late TextEditingController controller;
  TextFieldData({
    required this.key,
  }) {
    controller = TextEditingController();
  }
}

class Note extends StatefulWidget {
  static const routeName = 'note-page';

  const Note({
    Key? key,
  }) : super(key: key);
  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {
  stt.SpeechToText speech = stt.SpeechToText();
  TTS? tts;
  int newTextFieldKey = 0;
  int currentKey = 0;
  Map<int, TextFieldData> textFields = {};
  String _text = '';

  @override
  void initState() {
    super.initState();
    tts = TTS(setState);
    textFields.addAll({0: TextFieldData(key: 0)});
    newTextFieldKey++;
    startSTT();
  }

  void startSTT() {
    speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => setState(() {}),
    );
  }

  void _listen() {
    TextEditingController currentController =
        textFields[currentKey]!.controller;
    if (!speech.isAvailable) {
      return;
    }
    if (!speech.isListening) {
      _text = '';
      currentController.text = '';
      speech
          .listen(
            onResult: (val) => setState(() {
              currentController.text = _text + val.recognizedWords;
              if (val.finalResult) {
                _text += val.recognizedWords + ' ';
                currentController.text = _text;
              }
            }),
          )
          .then((value) => setState(() {}));
    } else {
      speech.stop().then((value) => setState(() {}));
    }
  }

  Widget _buildTextField(int key) {
    TextEditingController controller = textFields[key]!.controller;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
      child: Row(
        children: [
          IconButton(
            iconSize: 120,
            icon: Icon(
              Icons.mic,
              color: currentKey == key && speech.isListening
                  ? Colors.black
                  : Colors.grey,
            ),
            onPressed: () {
              currentKey = key;
              _listen();
            },
          ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 2,
              style: const TextStyle(fontSize: 30),
              decoration: InputDecoration(
                hintText: '특이사항이나 기타 사항을 알려주세요',
                hintStyle: const TextStyle(fontSize: 30),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(width: 10),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          IconButton(
            iconSize: 120,
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (textFields.length != 1)
                setState(() {
                  textFields.remove(key);
                });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userid = Provider.of<Auth>(context).userid;
    final result = Provider.of<Result>(context);

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
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.navigate_next, size: 40),
                    label: const Text(
                      '결과 보내기',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      result.notes = textFields.values
                          .map((textField) => textField.controller.text)
                          .toList();
                      bool success = await result.submit(userid!);
                      if (success) {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }
                    },
                  )
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: ListView.builder(
                itemCount: textFields.keys.length,
                itemBuilder: (context, index) => _buildTextField(
                  textFields.keys.toList()[index],
                ),
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 40),
              label: const Text(
                '추가',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                setState(() {
                  textFields.addAll(
                      {newTextFieldKey: TextFieldData(key: newTextFieldKey)});
                  newTextFieldKey++;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
