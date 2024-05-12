import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:tflite_flutter/tflite_flutter.dart';

class SignLanguageModel{

  CameraImage? cameraImage;
  List<Uint8List>? planes;
  List<List<List<List<double>>>> input=[];
  List<List<num>> out = [List<num>.filled(10, 0)];


  late Interpreter interpreter;

  Future<void> initialize() async {
    interpreter = await tfl.Interpreter.fromAsset('assets/ml/tmmodel.tflite');
  }

  List<num> runFromCamera(CameraImage cameraImage) {
    input = convertFromCamera(cameraImage);
    interpreter.run(input, out);
    return out[0];
  }

  List<num> runFromPlanes(List<Uint8List> planes) {
    input = convertFromPlanes(planes);
    interpreter.run(input, out);
    return out[0];
  }



  Uint8List yuv420ToRgba8888(List<Uint8List> planes, int width, int height) {
    final yPlane = planes[0];
    final uPlane = planes[1];
    final vPlane = planes[2];

    final Uint8List rgbaBytes = Uint8List(width * height * 4);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        final int uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);

        final int yValue = yPlane[yIndex] & 0xFF;
        final int uValue = uPlane[uvIndex] & 0xFF;
        final int vValue = vPlane[uvIndex] & 0xFF;

        final int r = (yValue + 1.13983 * (vValue - 128)).round().clamp(0, 255);
        final int g =
        (yValue - 0.39465 * (uValue - 128) - 0.58060 * (vValue - 128))
            .round()
            .clamp(0, 255);
        final int b = (yValue + 2.03211 * (uValue - 128)).round().clamp(0, 255);

        final int rgbaIndex = yIndex * 4;
        rgbaBytes[rgbaIndex] = r.toUnsigned(8);
        rgbaBytes[rgbaIndex + 1] = g.toUnsigned(8);
        rgbaBytes[rgbaIndex + 2] = b.toUnsigned(8);
        rgbaBytes[rgbaIndex + 3] = 255; // Alpha value
      }
    }

    return rgbaBytes;
  }
  List<List<List<List<double>>>> convertFromCamera(CameraImage cameraImage) {
    int imageWidth = cameraImage!.width;
    int imageHeight = cameraImage!.height;
    int imageStride = cameraImage!.planes[0].bytesPerRow;
    List<Uint8List> planes = [];
    for (int planeIndex = 0; planeIndex < 3; planeIndex++) {
      Uint8List buffer;
      int width;
      int height;
      if (planeIndex == 0) {
        width = cameraImage!.width;
        height = cameraImage!.height;
      } else {
        width = cameraImage!.width ~/ 2;
        height = cameraImage!.height ~/ 2;
      }

      buffer = Uint8List(width * height);

      int pixelStride = cameraImage!.planes[planeIndex].bytesPerPixel!;
      int rowStride = cameraImage!.planes[planeIndex].bytesPerRow;
      int index = 0;
      for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
          buffer[index++] = cameraImage!
              .planes[planeIndex].bytes[i * rowStride + j * pixelStride];
        }
      }

      planes.add(buffer);
    }
    Uint8List data = yuv420ToRgba8888(planes, 224, 224);
    // img.Image image = await createImage(data, 224, 224, img.PixelFormat.rgba8888);
    // img.Image? image = img.decodeImage(data);
    // image = img.copyResize(image!, width: 224, height: 224);
    // Uint8List d= image.getBytes();
    List<List<List<double>>> l3=[];
    int p=0;
    for(int i=0;i<224;i++){
      List<List<double>> l2=[];
      for(int j=0;j<224;j++){
        List<double> lst=[];
        for(int k=0;k<4;k++) {
          if(k<3) lst.add(data[p]/256.0);
          p++;
        }
        l2.add(lst);
      }
      l3.add(l2);
    }
    // input.add(l3);
    return [l3];
  }

  List<List<List<List<double>>>> convertFromPlanes(List<Uint8List> planes ){
    Uint8List data = yuv420ToRgba8888(planes, 224, 224);
    List<List<List<double>>> l3=[];
    int p=0;
    for(int i=0;i<224;i++){
      List<List<double>> l2=[];
      for(int j=0;j<224;j++){
        List<double> lst=[];
        for(int k=0;k<4;k++) {
          if(k<3) lst.add(data[p]/256.0);
          p++;
        }
        l2.add(lst);
      }
      l3.add(l2);
    }

    return [l3];
  }

  void dispose(){
    interpreter.close();
  }

}