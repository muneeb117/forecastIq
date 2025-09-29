import './market_accuracy_history.dart';
import './trend_point.dart';

class AssetTrends {
  final String symbol;
  final String timeframe;
  final double overallAccuracy;
  final List<MarketAccuracyHistory> accuracyHistory;
  final String timeframeLabel;
  final int predictionConfidence;
  final double marketVolatility;

  AssetTrends({
    required this.symbol,
    required this.timeframe,
    required this.overallAccuracy,
    required this.accuracyHistory,
    required this.timeframeLabel,
    required this.predictionConfidence,
    required this.marketVolatility,
  });

  factory AssetTrends.fromJson(Map<String, dynamic> json) {
    var historyList = json['accuracy_history'] as List<dynamic>? ?? [];
    List<MarketAccuracyHistory> history = historyList.map((item) => MarketAccuracyHistory.fromJson(item)).toList();

    return AssetTrends(
      symbol: json['symbol'] ?? '',
      timeframe: json['timeframe'] ?? '7D',
      overallAccuracy: (json['overall_accuracy'] ?? 0.0).toDouble(),
      accuracyHistory: history,
      timeframeLabel: json['timeframe_label'] ?? 'week',
      predictionConfidence: json['prediction_confidence'] ?? 0,
      marketVolatility: (json['market_volatility'] ?? 0.0).toDouble(),
    );
  }

  // Backward compatibility
  double get accuracy => overallAccuracy / 100.0;
  int get totalPredictions => accuracyHistory.length;
  int get correctPredictions => (totalPredictions * accuracy).round();
  List<TrendPoint> get trendData => accuracyHistory.map((h) => TrendPoint(
    date: DateTime.tryParse(h.date) ?? DateTime.now(),
    accuracy: h.accuracy,
    predictions: 1,
  )).toList();
}
