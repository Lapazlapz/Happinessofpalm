import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class PalmClassifier {
  late Interpreter _interpreter;

  static const String modelFile = "assets/palm_model.tflite";

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(modelFile);
    _interpreter.allocateTensors();
  }

  List<Map<String, dynamic>> classify(File imageFile) {
    // แปลงภาพให้ตรง input model
    final rawImage = img.decodeImage(imageFile.readAsBytesSync())!;
    final resized = img.copyResize(rawImage, width: 224, height: 224);

    var input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resized.getPixel(x, y);
return [
  pixel.r, // Red
  pixel.g, // Green
  pixel.b, // Blue
];

          },
        ),
      ),
    );

    var output = List.filled(4, 0.0).reshape([1, 4]);
    _interpreter.run(input, output);

    List<String> labels = ["ผลดิบ", "ผลสุก", "ผลที่เป็นโรค", "ผลเน่า"];
    List<Map<String, dynamic>> results = [];

    for (int i = 0; i < labels.length; i++) {
      results.add({
        "label": labels[i],
        "confidence": (output[0][i] as double) * 100
      });
    }

    results.sort((a, b) => b["confidence"].compareTo(a["confidence"]));
    return results;
  }
}
