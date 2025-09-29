class RealTimeUpdate {
  final String type;
  final String symbol;
  final double? currentPrice;
  final double? change24h;
  final int? confidence;
  final String? forecastDirection;
  final String? predictedRange;
  final DateTime timestamp;
  final double? volume;

  RealTimeUpdate({
    required this.type,
    required this.symbol,
    this.currentPrice,
    this.change24h,
    this.confidence,
    this.forecastDirection,
    this.predictedRange,
    required this.timestamp,
    this.volume,
  });

  factory RealTimeUpdate.fromJson(Map<String, dynamic> json) {
    return RealTimeUpdate(
      type: json['type'] ?? 'price_update',
      symbol: json['symbol'] ?? '',
      currentPrice: _parseDouble(json['current_price'] ?? json['price']),
      change24h: _parseDouble(json['change_24h']),
      confidence: _parseInt(json['confidence']),
      forecastDirection: json['forecast_direction']?.toString(),
      predictedRange: json['predicted_range']?.toString(),
      timestamp: _parseTimestamp(json),
      volume: _parseDouble(json['volume']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }



  static DateTime _parseTimestamp(Map<String, dynamic> json) {
    if (json['last_updated'] != null) {
      final parsed = DateTime.tryParse(json['last_updated']);
      if (parsed != null) return parsed;
    }

    if (json['timestamp'] != null) {
      final timeStr = json['timestamp'].toString();
      if (timeStr.contains(':') && timeStr.length <= 5) {
        final now = DateTime.now();
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? now.hour;
          final minute = int.tryParse(parts[1]) ?? now.minute;
          return DateTime(now.year, now.month, now.day, hour, minute);
        }
      }
      final parsed = DateTime.tryParse(timeStr);
      if (parsed != null) return parsed;
    }

    return DateTime.now();
  }
}
