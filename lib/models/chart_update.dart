import './models.dart';

class ChartUpdate {
  final String type;
  final String symbol;
  final String name;
  final String timeframe;
  final String forecastDirection;
  final int confidence;
  final String predictedRange;
  final double currentPrice;
  final double change24h;
  final double volume;
  final DateTime lastUpdated;
  final ChartData chartData;
  final int updateCount;

  ChartUpdate({
    required this.type,
    required this.symbol,
    required this.name,
    required this.timeframe,
    required this.forecastDirection,
    required this.confidence,
    required this.predictedRange,
    required this.currentPrice,
    required this.change24h,
    required this.volume,
    required this.lastUpdated,
    required this.chartData,
    required this.updateCount,
  });

  factory ChartUpdate.fromJson(Map<String, dynamic> json) {
    return ChartUpdate(
      type: json['type'] ?? 'chart_update',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      timeframe: json['timeframe'] ?? '',
      forecastDirection: json['forecast_direction'] ?? 'HOLD',
      confidence: json['confidence'] ?? 0,
      predictedRange: json['predicted_range'] ?? '--',
      currentPrice: RealTimeUpdate.parseDouble(json['current_price']) ?? 0.0,
      change24h: RealTimeUpdate.parseDouble(json['change_24h']) ?? 0.0,
      volume: RealTimeUpdate.parseDouble(json['volume']) ?? 0.0,
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
      chartData: ChartData.fromJson(json['chart'] ?? {}),
      updateCount: json['update_count'] ?? 0,
    );
  }
  double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
