import 'package:get/get.dart';
import 'dart:async';
import '../core/helpers/message_helper.dart';
import '../models/models.dart';
import '../services/trading_ai_service.dart';
import '../services/websocket_service.dart';
import '../services/favorites_service.dart';

abstract class AssetListController extends GetxController {
  // Services
  final TradingAIService tradingService = TradingAIService();
  late WebSocketService webSocketService;
  final FavoritesService favoritesService = FavoritesService.instance;

  // Observable state
  final RxInt selectedTabIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Market data
  final RxList<MarketSummary> allAssets = <MarketSummary>[].obs;
  final RxList<MarketSummary> cryptoAssets = <MarketSummary>[].obs;
  final RxList<MarketSummary> stockAssets = <MarketSummary>[].obs;
  final RxList<MarketSummary> macroAssets = <MarketSummary>[].obs;
  final RxList<MarketSummary> favoriteAssets = <MarketSummary>[].obs;

  // Real-time updates
  final RxMap<String, bool> isUpdating = <String, bool>{}.obs;
  StreamSubscription<RealTimeUpdate>? realTimeSubscription;
  Timer? debounceTimer;
  final Map<String, RealTimeUpdate> pendingUpdates = {};

  // Tab management
  final RxList<String> tabs = ['All', 'Stocks', 'Crypto', 'Macro', 'Favorites'].obs;

  @override
  void onInit() {
    super.onInit();
    webSocketService = WebSocketManager().getConnection('shared');
    initializeFavorites();
    loadMarketData();
  }

  @override
  void onClose() {
    debounceTimer?.cancel();
    realTimeSubscription?.cancel();
    favoritesService.removeListener(onFavoritesChanged);
    super.onClose();
  }

  // Tab management
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  // Favorites initialization
  void initializeFavorites() async {
    await favoritesService.init();
    favoritesService.addListener(onFavoritesChanged);
    updateFavoriteAssets();
  }

  void onFavoritesChanged(List<FavoriteItem> favorites) {
    updateFavoriteAssets();
  }

  void updateFavoriteAssets() {
    final favoriteSymbols = favoritesService.favorites.map((fav) => fav.symbol).toSet();
    favoriteAssets.value = allAssets.where((asset) => favoriteSymbols.contains(asset.symbol)).toList();
  }

  // Market data loading
  Future<void> loadMarketData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Fetch data for all categories in parallel
      final results = await Future.wait([
        tradingService.getMarketSummary(),
        tradingService.getMarketSummary(assetClass: 'crypto', limit: 10),
        tradingService.getMarketSummary(assetClass: 'stocks', limit: 10),
        tradingService.getMarketSummary(assetClass: 'macro', limit: 5),
      ]);

      allAssets.value = results[0];
      cryptoAssets.value = results[1];
      stockAssets.value = results[2];
      macroAssets.value = results[3];

      // Update favorites list with newly loaded market data
      updateFavoriteAssets();

      // Start real-time updates after loading initial data
      startRealTimeUpdates();

      isLoading.value = false;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      isLoading.value = false;

      MessageHelper.showError(
        'Failed to load market data: \${e.toString()}',
      );
    }
  }

  // Real-time updates
  void startRealTimeUpdates() {
    final allSymbols = allAssets.map((asset) => asset.symbol).toList();

    if (allSymbols.isNotEmpty) {
      // Apply cached updates if available
      webSocketService.latestUpdates.forEach((symbol, update) {
        updateAssetData(update);
      });

      // Ensure WebSocket is connected or connect if needed
      if (!webSocketService.isConnected) {
        webSocketService.connectToRealtimeUpdates(allSymbols);
      }

      // Setup stream listener
      realTimeSubscription?.cancel();
      realTimeSubscription = webSocketService.realTimeStream?.listen(
        (update) => handleRealTimeUpdate(update),
        onError: (error) {
          // Try to reconnect after a delay
          Future.delayed(Duration(seconds: 5), () {
            webSocketService.connectToRealtimeUpdates(allSymbols);
          });
        },
      );
    }
  }

  void handleRealTimeUpdate(RealTimeUpdate update) {
    // Process updates with any valid data
    if (update.currentPrice != null || update.confidence != null || update.predictedRange != null) {
      pendingUpdates[update.symbol] = update;

      debounceTimer?.cancel();
      debounceTimer = Timer(Duration(milliseconds: 100), () {
        pendingUpdates.forEach((symbol, update) {
          isUpdating[symbol] = true;
          updateAssetData(update);
        });
        pendingUpdates.clear();

        Future.delayed(Duration(milliseconds: 800), () {
          isUpdating.clear();
        });
      });
    }
  }

  void updateAssetData(RealTimeUpdate update) {
    // Update all assets list
    updateAssetList(allAssets, update);

    // Update crypto assets list
    updateAssetList(cryptoAssets, update);

    // Update stock assets list
    updateAssetList(stockAssets, update);

    // Update macro assets list
    updateAssetList(macroAssets, update);

    // Update favorites if needed
    updateFavoriteAssets();
  }

  void updateAssetList(RxList<MarketSummary> assetList, RealTimeUpdate update) {
    for (int i = 0; i < assetList.length; i++) {
      if (assetList[i].symbol == update.symbol) {
        assetList[i] = createUpdatedAsset(assetList[i], update);
        break;
      }
    }
  }

  MarketSummary createUpdatedAsset(MarketSummary original, RealTimeUpdate update) {
    return MarketSummary(
      type: original.type,
      symbol: original.symbol,
      name: original.name,
      timeframe: original.timeframe,
      forecastDirection: update.forecastDirection ?? original.forecastDirection,
      confidence: update.confidence ?? original.confidence,
      predictedRange: update.predictedRange ?? original.predictedRange,
      currentPrice: update.currentPrice ?? original.currentPrice,
      change24h: update.change24h ?? original.change24h,
      assetClass: original.assetClass,
      lastUpdated: update.timestamp,
    );
  }

  // Refresh functionality
  Future<void> refreshData() async {
    await loadMarketData();
  }

  // Get current tab assets
  List<MarketSummary> get currentTabAssets {
    switch (selectedTabIndex.value) {
      case 0: return allAssets;
      case 1: return stockAssets;
      case 2: return cryptoAssets;
      case 3: return macroAssets;
      case 4: return favoriteAssets;
      default: return allAssets;
    }
  }

  // Asset icon helper
  String? getAssetIcon(String symbol) {
    switch (symbol) {
      // All Crypto Coins with PNG Images
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
      default:
        return null;
    }
  }

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

  String formatPredictedRange(String? range) {
    if (range == null || range.isEmpty) return '-';

    try {
      final parts = range.split('–'); // split by en dash
      if (parts.length != 2) return range;

      final start = double.tryParse(parts[0].replaceAll(',', '').replaceAll('\$', ''));
      final end = double.tryParse(parts[1].replaceAll(',', '').replaceAll('\$', ''));

      if (start == null || end == null) return range;

      return '${formatPrice(start)}–${formatPrice(end)}';
    } catch (e) {
      return range;
    }
  }
}