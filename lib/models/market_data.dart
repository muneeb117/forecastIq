import '../services/websocket_service.dart';

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

class ForecastPoint {
  final DateTime timestamp;
  final double price;
  final double confidence;

  ForecastPoint({
    required this.timestamp,
    required this.price,
    required this.confidence,
  });

  factory ForecastPoint.fromJson(Map<String, dynamic> json) {
    return ForecastPoint(
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      price: (json['price'] ?? 0.0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class AssetTrends {
  final String symbol;
  final double accuracy;
  final int totalPredictions;
  final int correctPredictions;
  final List<TrendPoint> trendData;
  final String timeframe;

  AssetTrends({
    required this.symbol,
    required this.accuracy,
    required this.totalPredictions,
    required this.correctPredictions,
    required this.trendData,
    required this.timeframe,
  });

  factory AssetTrends.fromJson(Map<String, dynamic> json) {
    var trendList = json['trend_data'] as List<dynamic>? ?? [];
    List<TrendPoint> trends = trendList.map((trend) => TrendPoint.fromJson(trend)).toList();

    return AssetTrends(
      symbol: json['symbol'] ?? '',
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      totalPredictions: json['total_predictions'] ?? 0,
      correctPredictions: json['correct_predictions'] ?? 0,
      trendData: trends,
      timeframe: json['timeframe'] ?? '7D',
    );
  }
}

class TrendPoint {
  final DateTime date;
  final double accuracy;
  final int predictions;

  TrendPoint({
    required this.date,
    required this.accuracy,
    required this.predictions,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    return TrendPoint(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      predictions: json['predictions'] ?? 0,
    );
  }
}

class AssetSearch {
  final String symbol;
  final String name;
  final String assetClass;
  final bool hasForecasts;

  AssetSearch({
    required this.symbol,
    required this.name,
    required this.assetClass,
    required this.hasForecasts,
  });

  factory AssetSearch.fromJson(Map<String, dynamic> json) {
    return AssetSearch(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      assetClass: json['asset_class'] ?? '',
      hasForecasts: json['has_forecasts'] ?? false,
    );
  }
}

class ChartData {
  final List<double> pastPrices;
  final List<double> futurePrices;
  final List<DateTime> timestamps;
  final Map<String, dynamic>? confidenceBands;
  final Map<String, dynamic>? supportResistance;
  final Map<String, dynamic>? indicators;

  ChartData({
    required this.pastPrices,
    required this.futurePrices,
    required this.timestamps,
    this.confidenceBands,
    this.supportResistance,
    this.indicators,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    final chartJson = json['chart'] as Map<String, dynamic>? ?? {};

    List<double> past = [];
    List<double> future = [];
    List<DateTime> times = [];

    // Parse past prices
    if (chartJson['past'] != null) {
      past = (chartJson['past'] as List).map((e) => (e as num).toDouble()).toList();
    }

    // Parse future prices
    if (chartJson['future'] != null) {
      future = (chartJson['future'] as List).map((e) => (e as num).toDouble()).toList();
    }

    // Parse timestamps
    if (chartJson['timestamps'] != null) {
      times = (chartJson['timestamps'] as List).map((e) {
        try {
          return DateTime.parse(e.toString());
        } catch (_) {
          return DateTime.now();
        }
      }).toList();
    }

    return ChartData(
      pastPrices: past,
      futurePrices: future,
      timestamps: times,
      confidenceBands: chartJson['confidence_bands'],
      supportResistance: chartJson['support_resistance'],
      indicators: chartJson['indicators'],
    );
  }

  // Helper getters
  List<double> get allPrices => [...pastPrices, ...futurePrices];
  int get totalDataPoints => pastPrices.length + futurePrices.length;
  int get pastDataPoints => pastPrices.length;
  int get futureDataPoints => futurePrices.length;

  // Get price at specific index (combining past and future)
  double? getPriceAt(int index) {
    if (index < pastPrices.length) {
      return pastPrices[index];
    } else if (index < totalDataPoints) {
      return futurePrices[index - pastPrices.length];
    }
    return null;
  }

  // Get timestamp at specific index
  DateTime? getTimestampAt(int index) {
    if (index < timestamps.length) {
      return timestamps[index];
    }
    return null;
  }
}

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
  final ChartData? chartData;
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
    this.chartData,
    required this.updateCount,
  });

  factory ChartUpdate.fromJson(Map<String, dynamic> json) {
    return ChartUpdate(
      type: json['type'] ?? 'chart_update',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      timeframe: json['timeframe'] ?? '7D',
      forecastDirection: json['forecast_direction'] ?? 'HOLD',
      confidence: json['confidence'] ?? 0,
      predictedRange: json['predicted_range'] ?? '',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      change24h: (json['change_24h'] ?? 0.0).toDouble(),
      volume: (json['volume'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
      chartData: json['chart'] != null ? ChartData.fromJson(json) : null,
      updateCount: json['update_count'] ?? 0,
    );
  }

  // Convert to RealTimeUpdate for compatibility
  RealTimeUpdate toRealTimeUpdate() {
    return RealTimeUpdate(
      symbol: symbol,
      currentPrice: currentPrice,
      change24h: change24h,
      confidence: confidence,
      forecastDirection: forecastDirection,
      predictedRange: predictedRange,
      timestamp: lastUpdated,
      volume: volume,
      type: type,

    );
  }
}