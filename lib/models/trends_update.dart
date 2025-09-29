import './trends_chart.dart';
import './trends_history.dart';

class TrendsUpdate {
  final String type;
  final String symbol;
  final double accuracy;
  final TrendsChart chart;
  final List<TrendsHistory> history;
  final DateTime lastUpdated;

  TrendsUpdate({
    required this.type,
    required this.symbol,
    required this.accuracy,
    required this.chart,
    required this.history,
    required this.lastUpdated,
  });

  factory TrendsUpdate.fromJson(Map<String, dynamic> json) {
    return TrendsUpdate(
      type: json['type'] ?? 'trends_update',
      symbol: json['symbol'] ?? '',
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      chart: TrendsChart.fromJson(json['chart'] ?? {}),
      history: (json['history'] as List? ?? [])
          .map((item) => TrendsHistory.fromJson(item))
          .toList(),
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
    );
  }
}
