import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../services/favorites_service.dart';
import '../services/websocket_service.dart';
import '../models/models.dart';

class CoinDetailController extends GetxController {
  // Constructor parameters
  late String symbol;
  late String name;
  late String assetClass;

  // Services
  final FavoritesService _favoritesService = FavoritesService.instance;
  final WebSocketService _webSocketService = WebSocketService();

  // Observable state
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isFavorite = false.obs;
  final RxInt selectedTimeFrame = 0.obs;

  // Chart data
  ChartData? _chartData;
  final RxString currentPrice = '\$0.00'.obs;
  final RxString confidence = '0%'.obs;
  final RxString predictedRange = '--'.obs;
  final RxString forecastDirection = 'HOLD'.obs;
  final Rx<DateTime?> lastUpdated = Rx<DateTime?>(null);
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 0.0.obs;

  // WebSocket subscription
  StreamSubscription<ChartUpdate>? _chartSubscription;
  Timer? _reconnectTimer;

  // Screenshot
  final ScreenshotController screenshotController = ScreenshotController();

  // Time frames
  final List<String> timeFrames = ['1D', '1W', '1M', '3M', '6M', '1Y'];

  // Cache management
  bool _isInitialized = false;
  DateTime? _lastDataFetch;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Initialize with parameters
  void init(String symbolParam, String nameParam, String assetClassParam) {
    // Only initialize if not already done for this symbol
    if (_isInitialized && symbol == symbolParam) {
      _checkFavoriteStatus(); // Just update favorite status
      return;
    }

    symbol = symbolParam;
    name = nameParam;
    assetClass = assetClassParam;
    _isInitialized = true;

    _checkFavoriteStatus();

    // Check if we have valid cached data
    if (_hasValidCache()) {
      // Don't show loading if we have recent data
      isLoading.value = false;
    } else {
      _connectToWebSocketService();
    }
  }

  bool _hasValidCache() {
    return _chartData != null &&
           _lastDataFetch != null &&
           DateTime.now().difference(_lastDataFetch!) < _cacheValidDuration;
  }

  @override
  void onClose() {
    _chartSubscription?.cancel();
    _webSocketService.disconnect();
    _reconnectTimer?.cancel();
    super.onClose();
  }

  // Favorite management
  void _checkFavoriteStatus() {
    isFavorite.value = _favoritesService.isFavorite(symbol);
  }

  Future<void> toggleFavorite() async {
    try {
      if (isFavorite.value) {
        await _favoritesService.removeFromFavorites(symbol);
        isFavorite.value = false;
        Get.snackbar(
          'Removed',
          '$symbol removed from favorites',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );
      } else {
        await _favoritesService.addToFavorites(
          symbol: symbol,
          name: name,
          type: assetClass,
        );
        isFavorite.value = true;
        Get.snackbar(
          'Added',
          '$symbol added to favorites',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorites: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Time frame selection
  void changeTimeFrame(int index) {
    selectedTimeFrame.value = index;
    _refreshChart();
  }

  // WebSocket connection using shared service
  void _connectToWebSocketService() {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Cancel existing subscription
      _chartSubscription?.cancel();

      final apiTimeframe = _getApiTimeframe(timeFrames[selectedTimeFrame.value]);

      _webSocketService.connectToAssetChart(symbol, timeframe: apiTimeframe).then((_) {
        if (_webSocketService.chartStream != null) {
          _chartSubscription = _webSocketService.chartStream!.listen(
            (chartUpdate) => _handleChartUpdate(chartUpdate),
            onError: (error) => _handleWebSocketError(error),
            onDone: () => _handleWebSocketClosed(),
          );
        }
      }).catchError((error) {
        _handleWebSocketError(error.toString());
      });

      // Set timeout for initial data
      Timer(Duration(seconds: 10), () {
        if (isLoading.value) {
          _handleWebSocketError('Connection timeout');
        }
      });
    } catch (e) {
      _handleWebSocketError(e.toString());
    }
  }

  void _handleChartUpdate(ChartUpdate chartUpdate) {
    try {
      if (chartUpdate.symbol != symbol) return; // Ignore updates for other symbols

      _chartData = chartUpdate.chartData;

      // Update observable data
      currentPrice.value = '\$${chartUpdate.currentPrice.toStringAsFixed(2)}';
      confidence.value = '${chartUpdate.confidence}%';
      predictedRange.value = chartUpdate.predictedRange;
      forecastDirection.value = chartUpdate.forecastDirection;
      lastUpdated.value = chartUpdate.lastUpdated;

      // Calculate price range for chart display
      final allPrices = [...chartUpdate.chartData.pastPrices, ...chartUpdate.chartData.futurePrices];
      if (allPrices.isNotEmpty) {
        minPrice.value = allPrices.reduce((a, b) => a < b ? a : b);
        maxPrice.value = allPrices.reduce((a, b) => a > b ? a : b);
      }

      isLoading.value = false;
      hasError.value = false;
      _lastDataFetch = DateTime.now();
    } catch (e) {
      _handleWebSocketError('Failed to process chart update: ${e.toString()}');
    }
  }

  void _handleWebSocketError(dynamic error) {
    hasError.value = true;
    errorMessage.value = error.toString();
    isLoading.value = false;

    Get.snackbar(
      'Connection Error',
      'Failed to load chart data. Retrying...',
      snackPosition: SnackPosition.TOP,
    );

    // Retry connection after delay
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 3), () {
      if (!hasError.value) return;
      _connectToWebSocketService();
    });
  }

  void _handleWebSocketClosed() {
    if (!hasError.value) {
      _handleWebSocketError('Connection lost');
    }
  }

  // Chart refresh
  void _refreshChart() {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    _connectToWebSocketService();
  }

  void refreshChart() {
    _refreshChart();
  }

  // Screenshot and save functionality
  Future<void> saveChartToGallery() async {
    try {
      // Check if chart data is available
      if (isLoading.value || hasError.value || _chartData == null) {
        Get.snackbar(
          'Chart Not Ready',
          'Please wait for chart to load.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Check permissions
      if (!await Gal.hasAccess()) {
        if (!await Gal.requestAccess()) {
          throw Exception('Gallery access denied');
        }
      }

      // Capture screenshot
      final Uint8List? image = await screenshotController.capture();

      if (image != null) {
        // Get temporary directory
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = '${symbol}_chart_${DateTime.now().millisecondsSinceEpoch}.png';
        final File imageFile = File('${tempDir.path}/$fileName');

        // Write image to file
        await imageFile.writeAsBytes(image);

        // Save to gallery
        await Gal.putImage(imageFile.path, album: 'ForcastIQ Charts');

        // Clean up temporary file
        await imageFile.delete();

        Get.snackbar(
          'Success',
          'Chart saved to gallery successfully!',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );
      } else {
        throw Exception('Failed to capture chart');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save chart: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Price formatting
  String formatPrice(double price) {
    if (price >= 1000000) {
      double millions = price / 1000000;
      if (millions == millions.round()) {
        return '\$${millions.round()}M';
      } else {
        return '\$${millions.toStringAsFixed(2)}M';
      }
    } else if (price >= 1000) {
      double thousands = price / 1000;
      if (thousands == thousands.round()) {
        return '\$${thousands.round()}k';
      } else {
        return '\$${thousands.toStringAsFixed(2)}k';
      }
    } else if (price < 1) {
      return '\$${price.toStringAsFixed(4)}';
    } else {
      return '\$${price.toStringAsFixed(2)}';
    }
  }

  // Map UI timeframes to API timeframes
  String _getApiTimeframe(String uiTimeframe) {
    switch (uiTimeframe) {
      case '1D': return '1D';
      case '1W': return '7D';
      case '1M': return '1M';
      case '3M': return '3M';
      case '6M': return '6M';
      case '1Y': return '1Y';
      default: return '1D';
    }
  }

  // Getters
  bool get isChartReady => !isLoading.value && !hasError.value && _chartData != null;
  ChartData? get chartData => _chartData;
  String get currentTimeFrame => timeFrames[selectedTimeFrame.value];
}
