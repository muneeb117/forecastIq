import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Centralized helper class for color-related operations
/// Consolidates asset colors, notification colors, and market direction colors
class ColorHelper {
  ColorHelper._();

  // Asset color definitions
  static const Map<String, Color> _assetColors = {
    // Crypto Assets
    'BTC': Color(0xFFF7931A),
    'ETH': Color(0xFF627EEA),
    'USDT': Color(0xFF26A17B),
    'XRP': Color(0xFF23292F),
    'BNB': Color(0xFFF3BA2F),
    'SOL': Color(0xFF9945FF),
    'USDC': Color(0xFF2775CA),
    'DOGE': Color(0xFFC2A633),
    'ADA': Color(0xFF3CC8C8),
    'TRX': Color(0xFFFF060A),
    // Stock Assets
    'NVDA': Color(0xFF76B900),
    'MSFT': Color(0xFF00BCF2),
    'AAPL': Color(0xFF000000),
    'GOOGL': Color(0xFF4285F4),
    'AMZN': Color(0xFFFF9900),
    'META': Color(0xFF1877F2),
    'AVGO': Color(0xFFE30513),
    'TSLA': Color(0xFFCC0000),
    'BRK-B': Color(0xFF1F4E79),
    'JPM': Color(0xFF0066B2),
    // Macro Assets
    'GDP': Color(0xFF2E8B57),
    'CPI': Color(0xFFFF6347),
    'UNEMPLOYMENT': Color(0xFF9932CC),
    'FED_RATE': Color(0xFF4169E1),
    'CONSUMER_CONFIDENCE': Color(0xFFFF8C00),
  };

  // Notification type colors
  static const Map<String, Color> _notificationTypeColors = {
    'daily_asset_alert': AppColors.kgreen,
    'weekly_asset_alert': AppColors.kgreen,
    'realtime_asset_alert': AppColors.kgreen,
    'price_alert': AppColors.kred,
    'market_update': AppColors.kprimary,
    'test_alert': AppColors.kyellow,
    'external_test': AppColors.kprimary,
    'general': AppColors.kwhite2,
  };

  // Market direction colors
  static const Map<String, Color> _directionColors = {
    'UP': AppColors.kgreen,
    'DOWN': AppColors.kred,
    'HOLD': AppColors.kyellow,
    'NEUTRAL': AppColors.kwhite2,
    'BUY': AppColors.kgreen,
    'SELL': AppColors.kred,
    'STRONG_BUY': Color(0xFF00C851),
    'STRONG_SELL': Color(0xFFFF3547),
  };

  // Trend colors
  static const Map<String, Color> _trendColors = {
    'bullish': AppColors.kgreen,
    'bearish': AppColors.kred,
    'sideways': AppColors.kyellow,
    'volatile': AppColors.kprimary,
  };

  // Risk level colors
  static const Map<String, Color> _riskColors = {
    'low': AppColors.kgreen,
    'medium': AppColors.kyellow,
    'high': AppColors.kred,
    'very_high': Color(0xFFFF3547),
  };

  /// Get asset color
  /// Returns the brand color for a given asset symbol
  static Color getAssetColor(String symbol) {
    return _assetColors[symbol.toUpperCase()] ?? AppColors.kprimary;
  }

  /// Get notification type color
  /// Returns the color for a notification type
  static Color getNotificationTypeColor(String type) {
    return _notificationTypeColors[type.toLowerCase()] ?? AppColors.kwhite2;
  }

  /// Get market direction color
  /// Returns the color for market direction (UP/DOWN/HOLD etc.)
  static Color getDirectionColor(String direction) {
    return _directionColors[direction.toUpperCase()] ?? AppColors.kwhite2;
  }

  /// Get trend color
  /// Returns the color for market trend
  static Color getTrendColor(String trend) {
    return _trendColors[trend.toLowerCase()] ?? AppColors.kwhite2;
  }

  /// Get risk level color
  /// Returns the color for risk level
  static Color getRiskColor(String riskLevel) {
    return _riskColors[riskLevel.toLowerCase()] ?? AppColors.kwhite2;
  }

  /// Get percentage change color
  /// Returns green for positive, red for negative changes
  static Color getPercentageChangeColor(double percentage) {
    if (percentage > 0) return AppColors.kgreen;
    if (percentage < 0) return AppColors.kred;
    return AppColors.kwhite2;
  }

  /// Get price change color from string
  /// Handles formatted strings like "+5.2%" or "-3.1%"
  static Color getPriceChangeColorFromString(String percentageString) {
    if (percentageString.startsWith('+') ||
        (!percentageString.startsWith('-') && percentageString.contains('+'))) {
      return AppColors.kgreen;
    }
    if (percentageString.startsWith('-')) {
      return AppColors.kred;
    }
    return AppColors.kwhite2;
  }

  /// Get opacity variant of color
  /// Returns the color with specified opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get asset color with opacity
  /// Convenient method to get asset color with opacity
  static Color getAssetColorWithOpacity(String symbol, double opacity) {
    return getAssetColor(symbol).withOpacity(opacity);
  }

  /// Get complementary color
  /// Returns a contrasting color for readability
  static Color getComplementaryColor(Color color) {
    // Calculate luminance and return black or white for contrast
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Get all available asset colors
  static Map<String, Color> get availableAssetColors => Map.from(_assetColors);

  /// Get color scheme for asset
  /// Returns a complete color scheme for an asset
  static Map<String, Color> getAssetColorScheme(String symbol) {
    final baseColor = getAssetColor(symbol);
    return {
      'primary': baseColor,
      'light': baseColor.withOpacity(0.3),
      'lighter': baseColor.withOpacity(0.1),
      'dark': Color.lerp(baseColor, Colors.black, 0.3) ?? baseColor,
      'contrast': getComplementaryColor(baseColor),
    };
  }

  /// Get status color
  /// Returns color based on boolean status
  static Color getStatusColor(bool isPositive) {
    return isPositive ? AppColors.kgreen : AppColors.kred;
  }

  /// Get notification type icon color with background
  /// Returns both icon color and background color for notifications
  static Map<String, Color> getNotificationColorScheme(String type) {
    final baseColor = getNotificationTypeColor(type);
    return {
      'icon': baseColor,
      'background': baseColor.withOpacity(0.2),
      'border': baseColor.withOpacity(0.5),
    };
  }
}