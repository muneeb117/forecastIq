
/// Centralized helper class for price formatting operations
/// Consolidates all price formatting logic with consistent behavior
class PriceFormatter {
  PriceFormatter._();

  /// Format price with K/M/B suffixes
  /// Handles both integer and decimal formatting intelligently
  static String formatPrice(double price, {bool showCurrency = true, int decimalPlaces = 2}) {
    final prefix = showCurrency ? '\$' : '';

    if (price.abs() >= 1000000000) {
      // Billions
      final billions = price / 1000000000;
      if (billions == billions.round()) {
        return '$prefix${billions.round()}B';
      } else {
        return '$prefix${billions.toStringAsFixed(decimalPlaces)}B';
      }
    } else if (price.abs() >= 1000000) {
      // Millions
      final millions = price / 1000000;
      if (millions == millions.round()) {
        return '$prefix${millions.round()}M';
      } else {
        return '$prefix${millions.toStringAsFixed(decimalPlaces)}M';
      }
    } else if (price.abs() >= 1000) {
      // Thousands
      final thousands = price / 1000;
      if (thousands == thousands.round()) {
        return '$prefix${thousands.round()}K';
      } else {
        return '$prefix${thousands.toStringAsFixed(decimalPlaces)}K';
      }
    } else if (price.abs() >= 1) {
      // Regular numbers >= 1
      if (price == price.round()) {
        return '$prefix${price.round()}';
      } else {
        return '$prefix${price.toStringAsFixed(decimalPlaces)}';
      }
    } else {
      // Numbers < 1 (like 0.0012)
      return '$prefix${price.toStringAsFixed(6)}';
    }
  }

  /// Format price in short form (more aggressive abbreviation)
  static String formatPriceShort(double price, {bool showCurrency = true}) {
    return formatPrice(price, showCurrency: showCurrency, decimalPlaces: 1);
  }

  /// Format price from string input
  /// Handles string inputs like "109198.56" or "$28,432.12"
  static String formatPriceFromString(String priceString, {bool showCurrency = true, int decimalPlaces = 2}) {
    // Remove currency symbols and commas
    final cleanedString = priceString.replaceAll(RegExp(r'[\$,€£¥]'), '').trim();

    // Handle range format like "109198.56–113655.64"
    if (cleanedString.contains('–') || cleanedString.contains('-')) {
      return formatPriceRange(priceString, showCurrency: showCurrency, decimalPlaces: decimalPlaces);
    }

    final price = double.tryParse(cleanedString);
    if (price == null) return priceString; // Return original if parsing fails

    return formatPrice(price, showCurrency: showCurrency, decimalPlaces: decimalPlaces);
  }

  /// Format price range like "28.2k-29.4k"
  static String formatPriceRange(String rangeString, {bool showCurrency = true, int decimalPlaces = 2}) {
    // Handle different separators
    String separator = '–';
    if (rangeString.contains('–')) {
      separator = '–';
    } else if (rangeString.contains('-')) {
      separator = '-';
    } else if (rangeString.contains(' to ')) {
      separator = ' to ';
    }

    final parts = rangeString.split(separator);
    if (parts.length != 2) return rangeString; // Return original if not a valid range

    final price1 = _extractPriceFromString(parts[0]);
    final price2 = _extractPriceFromString(parts[1]);

    if (price1 == null || price2 == null) return rangeString;

    final formatted1 = formatPrice(price1, showCurrency: showCurrency, decimalPlaces: decimalPlaces);
    final formatted2 = formatPrice(price2, showCurrency: false, decimalPlaces: decimalPlaces); // No currency on second value

    return '$formatted1–$formatted2';
  }

  /// Extract price from string (helper method)
  static double? _extractPriceFromString(String priceString) {
    // Remove currency symbols, commas, and whitespace
    final cleanedString = priceString
        .replaceAll(RegExp(r'[\$,€£¥\s]'), '')
        .trim();

    return double.tryParse(cleanedString);
  }

  /// Format percentage change
  static String formatPercentageChange(double percentage, {int decimalPlaces = 2}) {
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(decimalPlaces)}%';
  }

  /// Format large numbers without currency
  static String formatLargeNumber(double number, {int decimalPlaces = 2}) {
    return formatPrice(number, showCurrency: false, decimalPlaces: decimalPlaces);
  }

  /// Format price with full precision (no abbreviation)
  static String formatPriceFull(double price, {bool showCurrency = true, int decimalPlaces = 2}) {
    final prefix = showCurrency ? '\$' : '';

    // Add thousand separators
    final formatter = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    final priceString = price.toStringAsFixed(decimalPlaces);
    final formattedPrice = priceString.replaceAllMapped(formatter, (Match m) => '${m[1]},');

    return '$prefix$formattedPrice';
  }

  /// Format crypto price (handles very small values)
  static String formatCryptoPrice(double price, {bool showCurrency = true}) {
    final prefix = showCurrency ? '\$' : '';

    if (price >= 1) {
      return formatPrice(price, showCurrency: showCurrency);
    } else if (price >= 0.01) {
      return '$prefix${price.toStringAsFixed(4)}';
    } else if (price >= 0.0001) {
      return '$prefix${price.toStringAsFixed(6)}';
    } else {
      return '$prefix${price.toStringAsFixed(8)}';
    }
  }

  /// Format market cap
  static String formatMarketCap(double marketCap) {
    return formatPrice(marketCap, showCurrency: true, decimalPlaces: 2);
  }

  /// Format volume
  static String formatVolume(double volume) {
    return formatPrice(volume, showCurrency: false, decimalPlaces: 2);
  }

  /// Format price change amount
  static String formatPriceChange(double change, {bool showCurrency = true}) {
    final prefix = showCurrency ? '\$' : '';
    final sign = change >= 0 ? '+' : '';

    if (change.abs() >= 1) {
      return '$sign$prefix${change.toStringAsFixed(2)}';
    } else {
      return '$sign$prefix${change.toStringAsFixed(4)}';
    }
  }

  /// Parse price string to double
  static double? parsePrice(String priceString) {
    return _extractPriceFromString(priceString);
  }

  /// Check if string contains price range
  static bool isPriceRange(String priceString) {
    return priceString.contains('–') ||
           priceString.contains('-') ||
           priceString.contains(' to ');
  }

  /// Get appropriate decimal places based on price value
  static int getOptimalDecimalPlaces(double price) {
    if (price >= 1000) return 0;
    if (price >= 100) return 1;
    if (price >= 1) return 2;
    if (price >= 0.01) return 4;
    return 6;
  }

  /// Format price with optimal decimal places
  static String formatPriceOptimal(double price, {bool showCurrency = true}) {
    final decimalPlaces = getOptimalDecimalPlaces(price);
    return formatPrice(price, showCurrency: showCurrency, decimalPlaces: decimalPlaces);
  }

  /// Format confidence percentage
  static String formatConfidence(double confidence) {
    return '${confidence.toStringAsFixed(0)}%';
  }

  /// Format prediction range
  static String formatPredictionRange(double low, double high, {bool showCurrency = true}) {
    final lowFormatted = formatPrice(low, showCurrency: showCurrency);
    final highFormatted = formatPrice(high, showCurrency: false);
    return '$lowFormatted–$highFormatted';
  }
}