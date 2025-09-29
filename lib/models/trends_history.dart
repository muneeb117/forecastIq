class TrendsHistory {
  final String date;
  final String forecast;
  final String actual;
  final String result;

  TrendsHistory({
    required this.date,
    required this.forecast,
    required this.actual,
    required this.result,
  });

  factory TrendsHistory.fromJson(Map<String, dynamic> json) {
    return TrendsHistory(
      date: json['date'] ?? '',
      forecast: json['forecast'] ?? '',
      actual: json['actual'] ?? '',
      result: json['result'] ?? '',
    );
  }
}
