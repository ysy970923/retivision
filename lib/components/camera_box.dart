import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retivision_v2/global.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:retivision_v2/native_opencv.dart';
import '../widgets/platform_alert_dialog.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

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

class CameraBox extends StatelessWidget {
  final int distanceLevel;
  const CameraBox({
    Key? key,
    required this.distanceLevel,
  }) : super(key: key);

  Text distanceText() {
    switch (distanceLevel) {
      case 0:
        return const Text('보이지 않습니다', style: TextStyle(color: Colors.red));
      case 1:
        return const Text('너무 멉니다', style: TextStyle(color: Colors.red));
      case 2:
        return const Text('적정 거리입니다', style: TextStyle(color: Colors.green));
      case 3:
        return const Text('너무 가깝습니다', style: TextStyle(color: Colors.red));
      default:
        return const Text('에러', style: TextStyle(color: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 3.0),
          borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        const Text('검사자와의 거리:'),
        const SizedBox(height: 20),
        distanceLevel != -1 ? distanceText() : const Text('카메라 준비 중'),
      ]),
    );
  }
}
