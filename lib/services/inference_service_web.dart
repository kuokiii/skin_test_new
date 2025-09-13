import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;

class InferenceService {
  List<String> labels = [];

  Future<void> init() async {
    final labelStr = await rootBundle.loadString('assets/labels.txt');
    labels = labelStr.split('\n').where((e) => e.trim().isNotEmpty).toList();
  }

  bool get ready => labels.isNotEmpty;

  Future<Map<String, dynamic>> classify(File imageFile) async {
    if (!ready) throw Exception("InferenceService not initialized");

    final probs = await _mockPredict();
    final topIdx = probs.indexWhere((p) => p == probs.reduce(math.max));
    return {
      "label": labels[topIdx],
      "confidence": probs[topIdx],
      "probs": probs,
      "mock": true
    };
  }

  Future<List<double>> _mockPredict() async {
    final rnd = math.Random();
    final raw = List<double>.generate(labels.length, (_) => rnd.nextDouble());
    final sum = raw.fold(0.0, (a, b) => a + b);
    return raw.map((e) => e / sum).toList();
  }
}
