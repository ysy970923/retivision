import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// C function signatures
typedef _CVersionFunc = ffi.Pointer<Utf8> Function();
// typedef _CGetDistanceFunc = ffi.Pointer<ffi.Uint8> Function(
//   ffi.Pointer<ffi.Uint8>,
//   ffi.Pointer<ffi.Uint8>,
//   ffi.Pointer<ffi.Uint8>,
//   ffi.Int32,
//   ffi.Int32,
// );
typedef _CGetDistanceFunc = ffi.Int32 Function(
  ffi.Pointer<ffi.Uint8>,
  ffi.Pointer<ffi.Uint8>,
  ffi.Pointer<ffi.Uint8>,
  ffi.Int32,
  ffi.Int32,
);

// Dart function signatures
typedef _VersionFunc = ffi.Pointer<Utf8> Function();
// typedef _GetDistanceFunc = ffi.Pointer<ffi.Uint8> Function(
//   ffi.Pointer<ffi.Uint8>,
//   ffi.Pointer<ffi.Uint8>,
//   ffi.Pointer<ffi.Uint8>,
//   int,
//   int,
// );
typedef _GetDistanceFunc = int Function(
  ffi.Pointer<ffi.Uint8>,
  ffi.Pointer<ffi.Uint8>,
  ffi.Pointer<ffi.Uint8>,
  int,
  int,
);

// Getting a library that holds needed symbols
ffi.DynamicLibrary _openDynamicLibrary() {
  if (Platform.isAndroid) {
    return ffi.DynamicLibrary.open('libnative_opencv.so');
  } else if (Platform.isWindows) {
    return ffi.DynamicLibrary.open("native_opencv_windows_plugin.dll");
  }

  return ffi.DynamicLibrary.process();
}

ffi.DynamicLibrary _lib = _openDynamicLibrary();

// Looking for the functions
final _VersionFunc _version =
    _lib.lookup<ffi.NativeFunction<_CVersionFunc>>('version').asFunction();
final _GetDistanceFunc _getDistance = _lib
    .lookup<ffi.NativeFunction<_CGetDistanceFunc>>('get_distance')
    .asFunction();

String opencvVersion() {
  return _version().toDartString();
}

int getDistance(Uint8List plane0, Uint8List plane1, Uint8List plane2, int width,
    int height) {
  ffi.Pointer<ffi.Uint8> yPlane = malloc.allocate<ffi.Uint8>(plane0.length);
  Uint8List plane0List = yPlane.asTypedList(plane0.length);
  plane0List.setRange(0, plane0.length, plane0);

  ffi.Pointer<ffi.Uint8> uPlane = malloc.allocate<ffi.Uint8>(plane1.length);
  Uint8List plane1List = uPlane.asTypedList(plane1.length);
  plane1List.setRange(0, plane1.length, plane1);

  ffi.Pointer<ffi.Uint8> vPlane = malloc.allocate<ffi.Uint8>(plane2.length);
  Uint8List plane2List = vPlane.asTypedList(plane2.length);
  plane2List.setRange(0, plane2.length, plane2);

  // ffi.Pointer<ffi.Uint8> imgP =
  //     _getDistance(plane0, plane1, plane2, args.width, args.height);
  int radius = _getDistance(yPlane, uPlane, vPlane, width, height);

  malloc.free(yPlane);
  malloc.free(uPlane);
  malloc.free(vPlane);

  return radius;

  // Uint8List imgData = imgP.asTypedList(args.width * args.height);
  // return imgData;
}

class ProcessImageArguments {
  final String inputPath;
  final String outputPath;

  ProcessImageArguments(this.inputPath, this.outputPath);
}

class GetDistanceArguments {
  final Uint8List plane0;
  final Uint8List plane1;
  final Uint8List plane2;
  final int width;
  final int height;

  GetDistanceArguments(
      this.plane0, this.plane1, this.plane2, this.width, this.height);
}
