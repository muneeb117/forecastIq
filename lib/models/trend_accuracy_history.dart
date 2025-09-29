class TrendAccuracyHistory {
  final String date;
  final double actual;
  final double predicted;
  final String result; // "Hit" or "Miss"
  final double errorPct;

  TrendAccuracyHistory({
    required this.date,
    required this.actual,
    required this.predicted,
    required this.result,
    required this.errorPct,
  });

  factory TrendAccuracyHistory.fromJson(Map<String, dynamic> json) {
    return TrendAccuracyHistory(
      date: json['date'] ?? '',
      actual: (json['actual'] as num?)?.toDouble() ?? 0.0,
      predicted: (json['predicted'] as num?)?.toDouble() ?? 0.0,
      result: json['result'] ?? '',
      errorPct: (json['error_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }

  bool get isHit => result.toLowerCase() == 'hit';
}
