class TrendsChart {
  final List<double> forecast;
  final List<double> actual;
  final List<String> timestamps;

  TrendsChart({
    required this.forecast,
    required this.actual,
    required this.timestamps,
  });

  factory TrendsChart.fromJson(Map<String, dynamic> json) {
    return TrendsChart(
      forecast: (json['forecast'] as List? ?? []).map((e) => (e as num).toDouble()).toList(),
      actual: (json['actual'] as List? ?? []).map((e) => (e as num).toDouble()).toList(),
      timestamps: (json['timestamps'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}
