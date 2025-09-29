class ForecastPoint {
  final DateTime timestamp;
  final double price;
  final double confidence;

  ForecastPoint({
    required this.timestamp,
    required this.price,
    required this.confidence,
  });

  factory ForecastPoint.fromJson(Map<String, dynamic> json) {
    return ForecastPoint(
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      price: (json['price'] ?? 0.0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}
