class MarketSummary {
  final String type;
  final String symbol;
  final String name;
  final String timeframe;
  final String forecastDirection;
  final int confidence;
  final String predictedRange;
  final double currentPrice;
  final double change24h;
  final String assetClass;
  final DateTime lastUpdated;

  MarketSummary({
    required this.type,
    required this.symbol,
    required this.name,
    required this.timeframe,
    required this.forecastDirection,
    required this.confidence,
    required this.predictedRange,
    required this.currentPrice,
    required this.change24h,
    required this.assetClass,
    required this.lastUpdated,
  });

  factory MarketSummary.fromJson(Map<String, dynamic> json) {
    return MarketSummary(
      type: json['data_source'] ?? 'Live API',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      timeframe: json['timeframe'] ?? '1D',
      forecastDirection: json['forecast_direction'] ?? 'HOLD',
      confidence: (json['confidence'] ?? 0.0).round(),
      predictedRange: json['predicted_range'] ?? '',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      change24h: (json['change_24h'] ?? 0.0).toDouble(),
      assetClass: json['asset_class'] ?? 'unknown',
      lastUpdated: DateTime.now(),
    );
  }

  static String _getAssetClassFromType(String type) {
    if (type.contains('crypto')) return 'crypto';
    if (type.contains('stock')) return 'stocks';
    if (type.contains('macro')) return 'macro';
    return 'unknown';
  }

  // Helper getter for percentage change
  double get changePercentage24h => change24h;
}
