import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/trading_ai_service.dart';
import '../models/models.dart';

class TrendController extends GetxController {
  // Observable state
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedTimeFrameIndex = 2.obs; // Default to 1D
  final RxString selectedCoinSymbol = 'BTC'.obs;
  final RxBool showDropdown = false.obs;
  final RxBool showTrendHistory = false.obs;
  final RxBool forecastVsActual = false.obs;

  // Data
  final Rx<TrendData?> trendData = Rx<TrendData?>(null);

  // Timeframes
  final List<String> timeFrames = ['1H', '4H', '1D', '7D', '1M'];

  // Available coins with metadata - dynamically populated from app data
  final RxList<Map<String, dynamic>> availableCoins = <Map<String, dynamic>>[].obs;

  // Services
  final TradingAIService _tradingService = TradingAIService();

  @override
  void onInit() {
    super.onInit();
    loadAvailableAssets();
    loadTrendData();
  }

  // Load available assets from the app (not hardcoded)
  Future<void> loadAvailableAssets() async {
    try {
      // Get available market data from your trading service
      final List<MarketSummary> allAssets = await _tradingService.getMarketSummary();

      // Convert to the format needed for dropdown
      final List<Map<String, dynamic>> assets = allAssets.map((asset) {
        return {
          'symbol': asset.symbol,
          'name': asset.name,
          'image': _getAssetIcon(asset.symbol),
          'assetClass': asset.assetClass,
        };
      }).toList();

      // Sort by asset class and symbol for better organization
      assets.sort((a, b) {
        int classCompare = a['assetClass'].compareTo(b['assetClass']);
        if (classCompare != 0) return classCompare;
        return a['symbol'].compareTo(b['symbol']);
      });

      availableCoins.value = assets;

      print('📊 Loaded ${assets.length} available assets for trends');
    } catch (e) {
      print('❌ Error loading available assets: $e');

      // Fallback to a minimal set of supported assets
      availableCoins.value = [
        {
          'symbol': 'BTC',
          'name': 'Bitcoin',
          'image': 'assets/images/btc.png',
          'assetClass': 'crypto',
        },
        {
          'symbol': 'ETH',
          'name': 'Ethereum',
          'image': 'assets/images/eth.png',
          'assetClass': 'crypto',
        },
      ];
    }
  }

  // Asset icon helper
  String? _getAssetIcon(String symbol) {
    switch (symbol) {
      case 'BTC':
        return 'assets/images/btc.png';
      case 'ETH':
        return 'assets/images/eth.png';
      case 'USDT':
        return 'assets/images/usdt.png';
      case 'XRP':
        return 'assets/images/xrp.png';
      case 'BNB':
        return 'assets/images/bnb.png';
      case 'SOL':
        return 'assets/images/sol.png';
      case 'USDC':
        return 'assets/images/usdc.png';
      case 'DOGE':
        return 'assets/images/doge.png';
      case 'ADA':
        return 'assets/images/ada.png';
      case 'TRX':
        return 'assets/images/trx.png';
      case 'REV':
        return 'assets/images/rev.png';
      default:
        return null;
    }
  }

  // Change timeframe
  void changeTimeFrame(int index) {
    if (selectedTimeFrameIndex.value != index) {
      selectedTimeFrameIndex.value = index;
      loadTrendData();
    }
  }

  // Change symbol
  void changeSymbol(String symbol) {
    if (selectedCoinSymbol.value != symbol) {
      selectedCoinSymbol.value = symbol;
      loadTrendData();
    }
  }

  // Toggle dropdown
  void toggleDropdown() {
    showDropdown.value = !showDropdown.value;
  }

  // Select coin
  void selectCoin(String symbol) {
    selectedCoinSymbol.value = symbol;
    showDropdown.value = false;
    loadTrendData();
  }

  // Toggle forecast vs actual
  void toggleForecastVsActual() {
    forecastVsActual.value = !forecastVsActual.value;
    showTrendHistory.value = forecastVsActual.value;
  }

  // Load trend data from API
  Future<void> loadTrendData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final timeframe = timeFrames[selectedTimeFrameIndex.value];
      final symbol = selectedCoinSymbol.value;

      final url = 'https://trading-production-85d8.up.railway.app/api/asset/$symbol/trends?timeframe=$timeframe';

      print('🔄 Loading trend data: $url');


      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        trendData.value = TrendData.fromJson(jsonData);
        print('✅ Trend data loaded successfully for $symbol $timeframe');
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('❌ Error loading trend data: $e');

      Get.snackbar(
        'Error',
        'Failed to load trend data: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadTrendData();
  }

  // Get current timeframe
  String get currentTimeFrame => timeFrames[selectedTimeFrameIndex.value];

  // Check if data is available
  bool get hasData => trendData.value != null &&
                     trendData.value!.chart.actual.isNotEmpty;

  // Get accuracy color based on percentage
  String getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return 'green';
    if (accuracy >= 60) return 'orange';
    return 'red';
  }

  // Get confidence color
  String getConfidenceColor(int confidence) {
    if (confidence >= 80) return 'green';
    if (confidence >= 60) return 'orange';
    return 'red';
  }

  // Format price
  String formatPrice(double price) {
    if (price >= 1000000) {
      return '\$${(price / 1000000).toStringAsFixed(2)}M';
    } else if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(2)}K';
    } else if (price < 1) {
      return '\$${price.toStringAsFixed(4)}';
    } else {
      return '\$${price.toStringAsFixed(2)}';
    }
  }

  // Format accuracy percentage
  String formatAccuracy(double accuracy) {
    return '${accuracy.toStringAsFixed(1)}%';
  }

  // Get hit rate from accuracy history
  double get hitRate {
    if (trendData.value == null || trendData.value!.accuracyHistory.isEmpty) {
      return 0.0;
    }

    final hits = trendData.value!.accuracyHistory.where((h) => h.isHit).length;
    final total = trendData.value!.accuracyHistory.length;

    return (hits / total) * 100;
  }

  // Get average error percentage
  double get averageError {
    if (trendData.value == null || trendData.value!.accuracyHistory.isEmpty) {
      return 0.0;
    }

    final totalError = trendData.value!.accuracyHistory
        .map((h) => h.errorPct)
        .reduce((a, b) => a + b);

    return totalError / trendData.value!.accuracyHistory.length;
  }

  // Get real-time accuracy for display
  String getRealTimeAccuracy(String symbol) {
    // If we have real data for the current symbol, use it
    if (symbol == selectedCoinSymbol.value && trendData.value != null) {
      return '${trendData.value!.overallAccuracy.toStringAsFixed(1)}%';
    }

    // Default fallback values based on symbol
    switch (symbol) {
      case 'BTC': return '86.9%';
      case 'ETH': return '78.5%';
      case 'NVDA': return '82.1%';
      case 'AAPL': return '75.3%';
      case 'MSFT': return '79.8%';
      case 'GDP': return '71.2%';
      case 'CPI': return '68.7%';
      default: return '75.0%';
    }
  }

  // Get selected coin name
  String getSelectedCoinName() {
    final coin = availableCoins.firstWhere(
      (c) => c['symbol'] == selectedCoinSymbol.value,
      orElse: () => {'name': 'Unknown'},
    );
    return coin['name'];
  }

  // Get selected coin accuracy
  String getSelectedCoinAccuracy() {
    if (trendData.value != null) {
      return '${trendData.value!.overallAccuracy.toStringAsFixed(1)}%';
    }
    return getRealTimeAccuracy(selectedCoinSymbol.value);
  }
}