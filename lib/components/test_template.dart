import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:retivision_v2/global.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:retivision_v2/native_opencv.dart';
import 'package:retivision_v2/pages/mchart.dart';
import 'package:retivision_v2/pages/test_grid.dart';
import 'package:retivision_v2/pages/test_hue.dart';
import 'package:retivision_v2/pages/test_landolt.dart';
import 'package:camera/camera.dart';
import 'package:retivision_v2/pages/test_reading.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../pages/note.dart';

// Image getArea(CameraImage image) {
//   final args = FindCircleArguments(
//     image.planes[0].bytes,
//     image.planes[1].bytes,
//     image.planes[2].bytes,
//     image.width,
//     image.height,
//   );
//   Uint8List imgData = getDistance(args);
//   imglib.Image img =
//       imglib.Image.fromBytes(image.width ~/ 2, image.height ~/ 2, imgData);
//   imglib.PngEncoder pngEncoder = imglib.PngEncoder();
//   List<int> png = pngEncoder.encodeImage(img);
//   return Image.memory(
//     Uint8List.fromList(png),
//     scale: 1.2,
//   );
// }

class TestTemplate extends StatefulWidget {
  final String testName;

  const TestTemplate({
    Key? key,
    required this.testName,
  }) : super(key: key);
  @override
  _TestTemplateState createState() => _TestTemplateState();
}

class _TestTemplateState extends State<TestTemplate> {
  late CameraController controller;
  late stt.SpeechToText speech;
  int nImages = 0;
  List<int> detectedRadius = [];
  int radius = 0;
  int distanceLevel =
      -1; // -1: 준비가 되지 않았습니다, 0: 보이지 않습니다, 1: 멉니다, 2: 적절합니다, 3: 가깝습니다
  final int randSeed = Random().nextInt(10);

  @override
  void initState() {
    super.initState();
    startCamera();
    startSTT();
  }

  void startSTT() {
    speech = stt.SpeechToText();
    speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
  }

  void startCamera() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      availableCameras().then(
        (cameras) {
          if (!mounted) return;
          controller = CameraController(
            cameras[1],
            ResolutionPreset.low,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.yuv420,
          );
          controller.initialize().then((value) {
            if (!mounted) return;
            controller
                .startImageStream((CameraImage image) => checkDistance(image))
                .then(
              (_) {
                setState(
                  () {
                    distanceLevel = -1;
                  },
                );
              },
            );
          });
        },
      );
    });
  }

  void checkDistance(CameraImage image) {
    int oldLevel = distanceLevel;
    nImages += 1;
    detectedRadius.add(getDistance(
      image.planes[0].bytes,
      image.planes[1].bytes,
      image.planes[2].bytes,
      image.width,
      image.height,
    ));
    if (nImages == 10) {
      nImages = 0;
      detectedRadius.sort();
      radius = detectedRadius[(detectedRadius.length * 0.5).toInt()];
      detectedRadius = [];
      if (radius < 1) {
        distanceLevel = 0;
      } else if (radius < global.baseRadius * 0.8) {
        distanceLevel = 1;
      } else if (radius < global.baseRadius * 1.2) {
        distanceLevel = 2;
      } else {
        distanceLevel = 3;
      }
    }
    if (oldLevel != distanceLevel) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    debugPrint("camaera box disposed----------------------------------------");
    controller.dispose();
    speech.cancel();
    super.dispose();
  }

  void nextPage(routeName) {
    controller.dispose().then(
          (_) => Navigator.of(context)
              .pushNamed(routeName)
              .then((_) => startCamera()),
        );
    speech.cancel();
  }

  Widget page() {
    switch (widget.testName) {
      case 'landolt':
        return TestLandolt(
          distanceLevel: distanceLevel,
          nextPage: () => nextPage(TestGridPage.routeName),
          speech: speech,
        );
      case 'grid':
        return TestGrid(
          distanceLevel: distanceLevel,
          nextPage: () => nextPage(TestHuePage.routeName),
          speech: speech,
        );
      case 'hue':
        return TestHue(
          distanceLevel: distanceLevel,
          nextPage: () => nextPage(TestHuePage.routeName),
          randSeed: randSeed,
        );
      case 'reading':
        return TestReading(
          distanceLevel: distanceLevel,
          nextPage: () => nextPage(Note.routeName),
          speech: speech,
        );
      case 'mchart':
        return TestMChart(
          distanceLevel: distanceLevel,
          nextPage: () => nextPage(Note.routeName),
          speech: speech,
        );
      default:
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retivision'),
      ),
      body: page(),
    );
  }
}
