import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/images.dart';

/// Centralized helper class for asset-related operations
/// Consolidates image paths, asset widgets, and asset metadata
class AssetHelper {
  AssetHelper._();

  // Crypto asset definitions
  static const Map<String, String> _cryptoImages = {
    'BTC': AppImages.btc,
    'ETH': AppImages.eth,
    'USDT': AppImages.usdt,
    'XRP': AppImages.xrp,
    'BNB': AppImages.bnb,
    'SOL': AppImages.sol,
    'USDC': AppImages.usdc,
    'DOGE': AppImages.doge,
    'ADA': AppImages.ada,
    'TRX': AppImages.trx,
  };

  // Asset full names mapping
  static const Map<String, String> _assetNames = {
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'USDT': 'Tether',
    'XRP': 'Ripple',
    'BNB': 'Binance Coin',
    'SOL': 'Solana',
    'USDC': 'USD Coin',
    'DOGE': 'Dogecoin',
    'ADA': 'Cardano',
    'TRX': 'TRON',
    // Stock assets
    'NVDA': 'NVIDIA',
    'MSFT': 'Microsoft',
    'AAPL': 'Apple Inc.',
    'GOOGL': 'Google',
    'AMZN': 'Amazon',
    'META': 'Meta Platforms',
    'AVGO': 'Broadcom',
    'TSLA': 'Tesla',
    'BRK-B': 'Berkshire Hathaway',
    'JPM': 'JPMorgan Chase',
    // Macro assets
    'GDP': 'Gross Domestic Product',
    'CPI': 'Consumer Price Index',
    'UNEMPLOYMENT': 'Unemployment Rate',
    'FED_RATE': 'Federal Interest Rate',
    'CONSUMER_CONFIDENCE': 'Consumer Confidence Index',
  };

  // Asset categories
  static const Map<String, String> _assetCategories = {
    'BTC': 'Crypto',
    'ETH': 'Crypto',
    'USDT': 'Crypto',
    'XRP': 'Crypto',
    'BNB': 'Crypto',
    'SOL': 'Crypto',
    'USDC': 'Crypto',
    'DOGE': 'Crypto',
    'ADA': 'Crypto',
    'TRX': 'Crypto',
    'NVDA': 'Stock',
    'MSFT': 'Stock',
    'AAPL': 'Stock',
    'GOOGL': 'Stock',
    'AMZN': 'Stock',
    'META': 'Stock',
    'AVGO': 'Stock',
    'TSLA': 'Stock',
    'BRK-B': 'Stock',
    'JPM': 'Stock',
    'GDP': 'Macro',
    'CPI': 'Macro',
    'UNEMPLOYMENT': 'Macro',
    'FED_RATE': 'Macro',
    'CONSUMER_CONFIDENCE': 'Macro',
  };

  /// Get asset image path
  /// Returns the image path for a given asset symbol
  static String? getAssetImagePath(String? symbol) {
    if (symbol == null) return null;
    return _cryptoImages[symbol.toUpperCase()];
  }

  /// Get asset name
  /// Returns the full name of an asset given its symbol
  static String getAssetName(String symbol) {
    return _assetNames[symbol.toUpperCase()] ?? symbol;
  }

  /// Get asset category
  /// Returns the category (Crypto, Stock, Macro) of an asset
  static String getAssetCategory(String symbol) {
    return _assetCategories[symbol.toUpperCase()] ?? 'Unknown';
  }

  /// Get asset widget
  /// Returns a properly sized Image widget for the asset
  static Widget getAssetWidget(String symbol, {double? width, double? height}) {
    final imagePath = getAssetImagePath(symbol);

    if (imagePath != null) {
      return Image.asset(
        imagePath,
        width: width ?? 20.w,
        height: height ?? 20.h,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackWidget(symbol, width: width, height: height);
        },
      );
    }

    return _buildFallbackWidget(symbol, width: width, height: height);
  }

  /// Build fallback widget for assets without images
  static Widget _buildFallbackWidget(String symbol, {double? width, double? height}) {
    return Container(
      width: width ?? 20.w,
      height: height ?? 20.h,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Center(
        child: Text(
          symbol.length > 2 ? symbol.substring(0, 2) : symbol,
          style: TextStyle(
            color: Colors.white,
            fontSize: (width ?? 20.w) * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Get asset metadata
  /// Returns comprehensive asset information
  static Map<String, dynamic> getAssetMetadata(String symbol) {
    return {
      'symbol': symbol.toUpperCase(),
      'name': getAssetName(symbol),
      'category': getAssetCategory(symbol),
      'imagePath': getAssetImagePath(symbol),
      'hasImage': getAssetImagePath(symbol) != null,
    };
  }

  /// Check if asset has image
  static bool hasAssetImage(String symbol) {
    return getAssetImagePath(symbol) != null;
  }

  /// Get all available crypto symbols
  static List<String> get availableCryptoSymbols => _cryptoImages.keys.toList();

  /// Get all available asset symbols
  static List<String> get availableAssetSymbols => _assetNames.keys.toList();

  /// Check if symbol is crypto
  static bool isCrypto(String symbol) {
    return _cryptoImages.containsKey(symbol.toUpperCase());
  }

  /// Check if symbol is stock
  static bool isStock(String symbol) {
    return getAssetCategory(symbol) == 'Stock';
  }

  /// Check if symbol is macro
  static bool isMacro(String symbol) {
    return getAssetCategory(symbol) == 'Macro';
  }
}