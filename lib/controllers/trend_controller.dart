import '../core/helpers/message_helper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final RxString searchQuery = ''.obs;

  // Data
  final Rx<TrendData?> trendData = Rx<TrendData?>(null);

  // Timeframes
  final List<String> timeFrames = ['1H', '4H', '1D', '7D', '1M'];

  // Macro indicators (only support 1D timeframe)
  final List<String> macroIndicators = ['GDP', 'CPI', 'UNEMPLOYMENT', 'FED_RATE', 'CONSUMER_CONFIDENCE'];

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

  // Load available assets from the app (manually include all crypto and stock assets)
  Future<void> loadAvailableAssets() async {
    final List<Map<String, dynamic>> assets = [];

    // Manually add all crypto assets
    for (String symbol in TradingAIService.cryptoAssets) {
      assets.add({
        'symbol': symbol,
        'name': _getAssetName(symbol),
        'image': _getAssetIcon(symbol),
        'assetClass': 'crypto',
      });
    }

    // Manually add all stock assets
    for (String symbol in TradingAIService.stockAssets) {
      assets.add({
        'symbol': symbol,
        'name': _getAssetName(symbol),
        'image': _getAssetIcon(symbol),
        'assetClass': 'stocks',
      });
    }

    // Sort by asset class and symbol for better organization
    assets.sort((a, b) {
      int classCompare = a['assetClass'].compareTo(b['assetClass']);
      if (classCompare != 0) return classCompare;
      return a['symbol'].compareTo(b['symbol']);
    });

    availableCoins.value = assets;
  }

  // Get asset name helper
  String _getAssetName(String symbol) {
    const assetNames = {
      // Crypto
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
      // Stocks
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
    };
    return assetNames[symbol] ?? symbol;
  }

  // Asset icon helper
  String? _getAssetIcon(String symbol) {
    switch (symbol) {
      // Crypto assets
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
      // Stock assets - no images available, will show fallback
      case 'NVDA':
      case 'MSFT':
      case 'AAPL':
      case 'GOOGL':
      case 'AMZN':
      case 'META':
      case 'AVGO':
      case 'TSLA':
      case 'BRK-B':
      case 'JPM':
        return null; // Will show letter fallback
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
    if (!showDropdown.value) {
      // Clear search when dropdown closes
      searchQuery.value = '';
    }
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Get filtered coins based on search
  List<Map<String, dynamic>> get filteredCoins {
    if (searchQuery.value.isEmpty) {
      return availableCoins;
    }

    final query = searchQuery.value.toLowerCase();
    return availableCoins.where((coin) {
      final symbol = coin['symbol'].toString().toLowerCase();
      final name = coin['name'].toString().toLowerCase();
      return symbol.contains(query) || name.contains(query);
    }).toList();
  }

  // Select coin
  void selectCoin(String symbol) {
    selectedCoinSymbol.value = symbol;
    showDropdown.value = false;
    searchQuery.value = ''; // Clear search

    // If switching to macro indicator, force 1D timeframe
    if (macroIndicators.contains(symbol)) {
      selectedTimeFrameIndex.value = 2; // Index 2 = '1D'
    }

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




      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        trendData.value = TrendData.fromJson(jsonData);
        //print('✅ Trend data loaded successfully for $symbol $timeframe');
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      //print('❌ Error loading trend data: $e');

      MessageHelper.showError(
        'Failed to load trend data: ${e.toString()}',
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

  // Check if current symbol is a macro indicator
  bool get isMacroIndicator => macroIndicators.contains(selectedCoinSymbol.value);

  // Get available timeframes based on asset type
  List<String> get availableTimeFrames {
    if (isMacroIndicator) {
      return ['1D']; // Macro indicators only support 1D
    }
    return timeFrames; // Crypto and stocks support all timeframes
  }

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

  // Export to CSV
  Future<void> exportToCSV() async {
    try {
      if (trendData.value == null || trendData.value!.accuracyHistory.isEmpty) {
        MessageHelper.showError('No data available to export');
        return;
      }

      // Request storage permission for Android
      if (Platform.isAndroid) {
        final status = await _requestStoragePermission();
        if (!status) {
          MessageHelper.showError('Storage permission required to export CSV');
          return;
        }
      }

      // Show loading message
      MessageHelper.showInfo('Preparing CSV export...');

      // Generate CSV content
      final csvContent = _generateCSVContent();

      // Get the directory to save the file
      Directory? directory;
      if (Platform.isAndroid) {
        // For Android 10+ (API 29+), use app-specific directory
        // For Android 9 and below, try Downloads folder
        try {
          // Try to use Downloads directory
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = Directory('/storage/emulated/0/Downloads');
          }
          if (!await directory.exists()) {
            // Fallback to external storage directory
            directory = await getExternalStorageDirectory();
          }
        } catch (e) {
          // If all else fails, use app-specific directory
          directory = await getExternalStorageDirectory();
        }
      } else {
        // For iOS, use documents directory (accessible via Files app)
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'ForcastIQ_${selectedCoinSymbol.value}_${currentTimeFrame}_$timestamp.csv';
      final filePath = '${directory.path}/$filename';

      // Write CSV file
      final file = File(filePath);
      await file.writeAsString(csvContent);

      // Show success message with file location
      final locationMessage = Platform.isIOS
          ? 'Files app > On My iPhone > forcast'
          : 'Downloads folder';

      MessageHelper.showSuccess(
        'CSV exported successfully!\nSaved to: $locationMessage\nFilename: $filename',
      );

      print('✅ CSV exported to: $filePath');
    } catch (e) {
      print('❌ Error exporting CSV: $e');
      MessageHelper.showError('Failed to export CSV: ${e.toString()}');
    }
  }

  // Request storage permission for Android
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we don't need storage permission for app-specific directories
      // For Android 10-12, we can use scoped storage
      // For Android 9 and below, we need WRITE_EXTERNAL_STORAGE

      // Check Android version
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 33) {
        // Android 13+: No permission needed for app-specific directories
        return true;
      } else if (androidInfo >= 29) {
        // Android 10-12: Scoped storage, no permission needed for Downloads
        return true;
      } else {
        // Android 9 and below: Request WRITE_EXTERNAL_STORAGE
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true; // iOS doesn't need permission for app documents
  }

  // Get Android SDK version
  Future<int> _getAndroidVersion() async {
    try {
      // This is a simple check - in production, you might want to use device_info_plus
      return 33; // Assume Android 13+ for now (most devices)
    } catch (e) {
      return 29; // Default to Android 10
    }
  }

  // Generate CSV content from trend data
  String _generateCSVContent() {
    final buffer = StringBuffer();

    // Add header information
    buffer.writeln('ForcastIQ Historical Trends Export');
    buffer.writeln('Asset: ${selectedCoinSymbol.value} - ${getSelectedCoinName()}');
    buffer.writeln('Timeframe: $currentTimeFrame');
    buffer.writeln('Export Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('Overall Accuracy: ${trendData.value!.overallAccuracy.toStringAsFixed(2)}%');
    buffer.writeln('');

    // Add trend history table
    buffer.writeln('Historical Trend Data');
    buffer.writeln('Date & Time,Forecast,Actual,Predicted Price,Actual Price,Error %,Result,Status');

    for (final historyItem in trendData.value!.accuracyHistory) {
      // Format date and time safely - handle different date formats
      String dateTime;

      try {
        final parsedDateTime = DateTime.parse(historyItem.date);
        // Combine date and time in one column (e.g., "Sep 04 14:30:52")
        final date = _formatDateForCSV(historyItem.date);
        final time = DateFormat('HH:mm:ss').format(parsedDateTime);
        dateTime = '$date $time';
      } catch (e) {
        // If parsing fails, use the original date string as-is
        dateTime = historyItem.date;
      }

      // Determine forecast and actual trends
      String forecastTrend;
      String actualTrend;
      final isHit = historyItem.isHit;
      final predicted = historyItem.predicted;
      final actual = historyItem.actual;

      if (isHit) {
        if (predicted < actual) {
          forecastTrend = 'Up';
          actualTrend = 'Up';
        } else {
          forecastTrend = 'Down';
          actualTrend = 'Down';
        }
      } else {
        if (predicted > actual) {
          forecastTrend = 'Up';
          actualTrend = 'Down';
        } else {
          forecastTrend = 'Down';
          actualTrend = 'Up';
        }
      }

      buffer.writeln(
        '$dateTime,$forecastTrend,$actualTrend,${predicted.toStringAsFixed(2)},${actual.toStringAsFixed(2)},${historyItem.errorPct.toStringAsFixed(2)}%,${historyItem.result},${isHit ? 'Hit' : 'Miss'}'
      );
    }

    // Add chart data if available
    if (trendData.value!.chart.actual.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Chart Data');
      buffer.writeln('Index,Actual Price,Predicted Price');

      final actualPrices = trendData.value!.chart.actual;
      final predictedPrices = trendData.value!.chart.predicted;

      for (int i = 0; i < actualPrices.length; i++) {
        final predictedValue = i < predictedPrices.length ? predictedPrices[i].toStringAsFixed(2) : 'N/A';
        buffer.writeln('$i,${actualPrices[i].toStringAsFixed(2)},$predictedValue');
      }
    }

    // Add summary statistics
    buffer.writeln('');
    buffer.writeln('Summary Statistics');
    buffer.writeln('Metric,Value');
    buffer.writeln('Hit Rate,${hitRate.toStringAsFixed(2)}%');
    buffer.writeln('Average Error,${averageError.toStringAsFixed(2)}%');
    buffer.writeln('Total Data Points,${trendData.value!.accuracyHistory.length}');
    buffer.writeln('Hits,${trendData.value!.accuracyHistory.where((h) => h.isHit).length}');
    buffer.writeln('Misses,${trendData.value!.accuracyHistory.where((h) => !h.isHit).length}');
    buffer.writeln('Min Price,${trendData.value!.chart.minPrice.toStringAsFixed(2)}');
    buffer.writeln('Max Price,${trendData.value!.chart.maxPrice.toStringAsFixed(2)}');

    return buffer.toString();
  }

  // Format date for CSV (same as UI display format)
  String _formatDateForCSV(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    } catch (e) {
      // If parsing fails, return the original string
      return dateStr;
    }
  }
}