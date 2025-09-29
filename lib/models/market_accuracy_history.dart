class MarketAccuracyHistory {
  final String date;
  final double accuracy;
  final String period;

  MarketAccuracyHistory({
    required this.date,
    required this.accuracy,
    required this.period,
  });

  factory MarketAccuracyHistory.fromJson(Map<String, dynamic> json) {
    return MarketAccuracyHistory(
      date: json['date'] ?? '',
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      period: json['period'] ?? '',
    );
  }
}
