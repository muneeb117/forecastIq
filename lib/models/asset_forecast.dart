class AssetForecast {
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
  final Map<String, dynamic>? chart;

  AssetForecast({
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
    this.chart,
  });

  factory AssetForecast.fromJson(Map<String, dynamic> json) {
    return AssetForecast(
      type: json['type'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      timeframe: json['timeframe'] ?? '1D',
      forecastDirection: json['forecast_direction'] ?? 'HOLD',
      confidence: json['confidence'] ?? 0,
      predictedRange: json['predicted_range'] ?? '',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      change24h: (json['change_24h'] ?? 0.0).toDouble(),
      volume: (json['volume'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
      chart: json['chart'],
    );
  }

  // Helper getters for backward compatibility
  double get predictedPrice => currentPrice + change24h;
  double get priceChange => change24h;
  double get priceChangePercentage => (change24h / currentPrice) * 100;
  String get direction => forecastDirection;
}
