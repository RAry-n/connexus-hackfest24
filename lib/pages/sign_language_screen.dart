import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../constants/my_colors.dart';
import '../main.dart';
import '../themes/text_themes.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'dart:typed_data';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
class SignLanguageScreen extends StatefulWidget {
  const SignLanguageScreen({super.key});

  @override
  State<SignLanguageScreen> createState() => _SignLanguageScreenState();
}

class _SignLanguageScreenState extends State<SignLanguageScreen> {
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = "";
  String word="";
  int cameraCnt=0;
  int maxLength = 15;

  @override
  void initState() {
    super.initState();
    loadCamera();
  }
  @override
  void dispose()
  {
    cameraController?.dispose();
    super.dispose();
  }
  loadCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.low);
    cameraController!.initialize().then((value) {
      if (mounted) {
        setState(() {
          cameraController!.startImageStream((imageStream) {
            cameraImage = imageStream;
            cameraCnt++;
            if(cameraCnt%30==0)
            {
              cameraCnt=1;
              //runModel();
              runInterpreter();
            }
            // runModel();
          });
        });
      }
    });
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
  List<List<List<List<double>>>> convertInput() {
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
  runInterpreter() async
  {
    final interpreter = await tfl.Interpreter.fromAsset('assets/ml/tmmodel.tflite');

    List<List<List<List<double>>>> input = convertInput();

    List<List<num>> out = [List<num>.filled(10, 0)];
    interpreter.run(input, out);
    print(out);
    processOutput(out[0]);
    interpreter.close();
  }
  List<String> labels = [
    'hello ',
    'please ',
    'bye ',
    'drink ',
    'eat ',
    'I ',
    'love you ',
    'no ',
    'yes ',
    'thank you '
  ];
  void processOutput(List<num> outList){
    int j=0;
    for(int i=0;i<10;i++){
      if(outList[j]<outList[i]) j=i;
    }
    if(outList[j]<0.5) return;
    output+=labels[j];
    speak('en', labels[j]);

    if(output.length>maxLength){
      output=output.substring(output.length - maxLength);
    }
    setState(() {

    });
  }



  final flutterTts = FlutterTts();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.appBarColor,
        titleTextStyle: TextThemes.appBar,
        title: const Text('SignLanguage'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: !cameraController!.value.isInitialized
                  ? Container()
                  : AspectRatio(
                aspectRatio: cameraController!.value.aspectRatio,
                child: CameraPreview(cameraController!),
              ),
            ),
          ),
          Text(
            output,
            style: const TextStyle(
              color: MyColors.text,
              fontWeight: FontWeight.w300,
              fontFamily: 'Futura',
            ),
          )
        ],
      ),
    );
  }

  Future speak(String languageCode, String text) async {
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setPitch(1);
    await flutterTts.setVolume(1);
    await flutterTts.setSpeechRate(1);
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }
}
