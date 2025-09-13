import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'dart:math' as math;

class InferenceService {
  Interpreter? _interpreter;
  List<String> labels = [];
  ImageProcessor? _processor;
  bool _mockMode = false;

  Future<void> init() async {
    // Load labels
    final labelStr = await rootBundle.loadString('assets/labels.txt');
    labels = labelStr.split('\n').where((e) => e.trim().isNotEmpty).toList();

    // Build processor (224x224) — match your model
    _processor = ImageProcessorBuilder()
        .add(ResizeOp(224, 224, ResizeMethod.NEAREST_NEIGHBOR))
        .build();

    // Try to load model
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/skin_classifier_quant.tflite',
          options: InterpreterOptions()..threads = 4);
    } catch (_) {
      // Fallback to mock if model missing
      _mockMode = true;
    }
  }

  bool get ready => _processor != null && labels.isNotEmpty;

  Future<List<double>> _mockPredict() async {
    // Produce a stable pseudo-probability vector
    final rnd = math.Random();
    final raw = List<double>.generate(labels.length, (_) => rnd.nextDouble());
    final sum = raw.fold(0.0, (a, b) => a + b);
    return raw.map((e) => e / sum).toList();
  }

  Future<Map<String, dynamic>> classify(File imageFile) async {
    if (!ready) throw Exception("InferenceService not initialized");

    if (_mockMode) {
      final probs = await _mockPredict();
      final topIdx = probs.indexWhere((p) => p == probs.reduce(math.max));
      return {
        "label": labels[topIdx],
        "confidence": probs[topIdx],
        "probs": probs,
        "mock": true
      };
    }

    // Real inference
    final tensorImage = TensorImage.fromFile(imageFile);
    final input = _processor!.process(tensorImage);
    final inputBuffer = input.tensorBuffer.buffer;

    // Determine output shape/dtype dynamically
    final outTensors = _interpreter!.getOutputTensors();
    final outShape = outTensors.first.shape;
    final outType = outTensors.first.type;

    TensorBuffer output;
    if (outType == TfLiteType.uint8) {
      output = TensorBuffer.createFixedSize(outShape, TfLiteType.uint8);
    } else {
      output = TensorBuffer.createFixedSize(outShape, TfLiteType.float32);
    }

    _interpreter!.run(inputBuffer, output.buffer);

    List<double> probs;
    if (output.type == TfLiteType.uint8) {
      final ints = output.getIntList();
      probs = ints.map((e) => e / 255.0).toList();
    } else {
      probs = output.getDoubleList();
    }

    // Softmax if needed
    if (probs.length != labels.length) {
      // Sometimes output shape is [1, N]; normalize accordingly
      if (probs.isNotEmpty) {
        final maxV = probs.reduce(math.max);
        final exps = probs.map((x) => math.exp(x - maxV)).toList();
        final sum = exps.fold(0.0, (a, b) => a + b);
        probs = exps.map((e) => e / sum).toList();
      }
    }

    final topIdx = probs.indexWhere((p) => p == probs.reduce(math.max));
    return {
      "label": labels[topIdx],
      "confidence": probs[topIdx],
      "probs": probs,
      "mock": false
    };
  }
}
