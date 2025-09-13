class Prediction {
  final String label;
  final double confidence;
  final String imagePath;
  final DateTime timestamp;
  const Prediction({required this.label, required this.confidence, required this.imagePath, required this.timestamp});

  Map<String, dynamic> toJson() => {
    "label": label,
    "confidence": confidence,
    "imagePath": imagePath,
    "timestamp": timestamp.toIso8601String(),
  };

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
    label: json["label"],
    confidence: (json["confidence"] as num).toDouble(),
    imagePath: json["imagePath"],
    timestamp: DateTime.parse(json["timestamp"]),
  );
}
