import './chart_trend_data.dart';
import './trend_accuracy_history.dart';

class TrendData {
  final String symbol;
  final String timeframe;
  final double overallAccuracy;
  final ChartTrendData chart;
  final List<TrendAccuracyHistory> accuracyHistory;
  final int predictionConfidence;
  final double marketVolatility;

  TrendData({
    required this.symbol,
    required this.timeframe,
    required this.overallAccuracy,
    required this.chart,
    required this.accuracyHistory,
    required this.predictionConfidence,
    required this.marketVolatility,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      symbol: json['symbol'] ?? '',
      timeframe: json['timeframe'] ?? '',
      overallAccuracy: (json['overall_accuracy'] as num?)?.toDouble() ?? 0.0,
      chart: ChartTrendData.fromJson(json['chart'] ?? {}),
      accuracyHistory: (json['accuracy_history'] as List?)
          ?.map((item) => TrendAccuracyHistory.fromJson(item))
          .toList() ?? [],
      predictionConfidence: json['prediction_confidence'] ?? 0,
      marketVolatility: (json['market_volatility'] as num?)?.toDouble() ?? 0.0,
    );
  }
}