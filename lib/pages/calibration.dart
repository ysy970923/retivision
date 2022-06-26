import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retivision_v2/global.dart';
import 'package:retivision_v2/pages/mchart.dart';
import 'package:retivision_v2/pages/test_hue.dart';
import 'package:retivision_v2/pages/test_landolt.dart';
import 'package:retivision_v2/native_opencv.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Calibration extends StatefulWidget {
  static const routeName = 'calibration-page';
  const Calibration({Key? key}) : super(key: key);

  @override
  State<Calibration> createState() => _CalibrationState();
}

class _CalibrationState extends State<Calibration> {
  int radius = 0;
  List<int> detectedRadius = [];
  int nImages = 0;
  bool cameraReady = false;
  bool distanceDetected = false;
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    startCamera();
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
                    cameraReady = true;
                  },
                );
              },
            );
          });
        },
      );
    });
  }

  void nextPage() {
    setState(() {
      distanceDetected = false;
    });
    controller.dispose().then(
          (value) => Navigator.of(context)
              .pushNamed(TestMChartPage.routeName)
              .then((value) => startCamera()),
        );
  }

  void checkDistance(CameraImage image) {
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
      if (radius < 2 && distanceDetected) {
        setState(() {
          distanceDetected = false;
        });
      }
      if (radius >= 3 && !distanceDetected) {
        setState(() {
          distanceDetected = true;
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retivision'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('테스트를 진행할 적정거리를 설정합니다.'),
            const SizedBox(height: 20),
            const Text('안경을 착용하고 적절한 위치에서 멈춰주세요.'),
            const SizedBox(height: 80),
            cameraReady
                ? Text(
                    distanceDetected ? '적절한 거리에서 버튼을 눌러주세요' : '화면에 잡히지 않습니다.')
                : const Text('카메라 준비 중'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: cameraReady
                  ? () {
                      global.baseRadius = radius;
                      nextPage();
                    }
                  : null,
              child: Text(distanceDetected ? '테스트 시작' : '무시하고 테스트 시작'),
            ),
          ],
        ),
      ),
    );
  }
}
