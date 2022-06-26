import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TTS {
  Function callback;
  TTS(this.callback);

  final FlutterTts flutterTts = FlutterTts();
  dynamic? languages;
  String? language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.3;
  bool isCurrentLanguageInstalled = false;
  TtsState ttsState = TtsState.stopped;

  initTts() {
    _getEngines();

    flutterTts.setStartHandler(() {
      print("Playing");
      ttsState = TtsState.playing;
      callback();
    });

    flutterTts.setCompletionHandler(() {
      print("Complete");
      ttsState = TtsState.stopped;
      callback();
    });

    flutterTts.setCancelHandler(() {
      print("Cancel");
      ttsState = TtsState.stopped;
      callback();
    });

    flutterTts.setErrorHandler((msg) {
      print("error: $msg");
      ttsState = TtsState.stopped;
      callback();
    });
  }

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future<dynamic> _getEngines() => flutterTts.getEngines;

  Future speak(String voiceText) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (voiceText.isNotEmpty) {
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.speak(voiceText);
    }
  }

  Future stop() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      ttsState = TtsState.stopped;
      callback();
    }
  }

  void dispose() {
    flutterTts.stop();
  }
}
