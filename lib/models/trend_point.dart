class TrendPoint {
  final DateTime date;
  final double accuracy;
  final int predictions;

  TrendPoint({
    required this.date,
    required this.accuracy,
    required this.predictions,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    return TrendPoint(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      predictions: json['predictions'] ?? 0,
    );
  }
}
