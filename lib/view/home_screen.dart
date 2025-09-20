import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';
import '../widgets/Item_Widget.dart';
import 'coin_detail_screen.dart';
import '../services/trading_ai_service.dart';
import '../services/websocket_service.dart';
import '../models/market_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  final TradingAIService _tradingService = TradingAIService();
  late WebSocketService _webSocketService;
  StreamSubscription<RealTimeUpdate>? _realTimeSubscription;

  List<MarketSummary> _allAssets = [];
  List<MarketSummary> _cryptoAssets = [];
  List<MarketSummary> _stockAssets = [];
  List<MarketSummary> _macroAssets = [];
  List<MarketSummary> _favoriteAssets = [];
  bool _isLoading = true;

  // Animation controllers for real-time update indicators
  Map<String, bool> _isUpdating = {};

  // Debouncing for frequent updates
  Timer? _debounceTimer;
  Map<String, RealTimeUpdate> _pendingUpdates = {};

  final List<String> _tabs = ['All', 'Stocks', 'Crypto', 'Macro', 'Favorites'];

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketManager().getConnection('shared');
    _loadMarketData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _realTimeSubscription?.cancel();
    // Do not dispose WebSocketService to persist connection
    super.dispose();
  }

  Future<void> _loadMarketData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch data for all categories in parallel
      final results = await Future.wait([
        _tradingService.getMarketSummary(),
        _tradingService.getMarketSummary(assetClass: 'crypto', limit: 10),
        _tradingService.getMarketSummary(assetClass: 'stocks', limit: 10),
        _tradingService.getMarketSummary(assetClass: 'macro', limit: 5),
      ]);

      setState(() {
        _allAssets = results[0];
        _cryptoAssets = results[1];
        _stockAssets = results[2];
        _macroAssets = results[3];
        _isLoading = false;
      });

      // Start real-time updates after loading initial data
      _startRealTimeUpdates();
    } catch (e) {
      print('Error loading market data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _startRealTimeUpdates() {
    // Collect all symbols for real-time updates
    final allSymbols = _allAssets.map((asset) => asset.symbol).toList();

    if (allSymbols.isNotEmpty) {
      print('🚀 [HOME] Starting real-time updates for symbols: $allSymbols');
      print('📊 [HOME] Crypto symbols: ${_cryptoAssets.map((a) => a.symbol).toList()}');
      print('📈 [HOME] Stock symbols: ${_stockAssets.map((a) => a.symbol).toList()}');
      print('🌍 [HOME] Macro symbols: ${_macroAssets.map((a) => a.symbol).toList()}');

      // Apply cached updates if available
      _webSocketService.latestUpdates.forEach((symbol, update) {
        _updateAssetData(update);
      });

      // Ensure WebSocket is connected or connect if needed
      if (!_webSocketService.isConnected) {
        print('🔗 [HOME] Connecting to WebSocket...');
        _webSocketService.connectToRealtimeUpdates(allSymbols);
      } else {
        print('✅ [HOME] WebSocket already connected, reusing connection');
      }

      // Always setup stream listener (even if connection exists)
      _realTimeSubscription?.cancel();

      print('🎧 [HOME] Setting up stream listener, stream available: ${_webSocketService.realTimeStream != null}');

      _realTimeSubscription = _webSocketService.realTimeStream?.listen(
        (update) {
          print('📨 [HOME] Received WebSocket update for ${update.symbol}');
          _handleRealTimeUpdate(update);
        },
        onError: (error) {
          print('❌ [HOME] Real-time update error: $error');
          // Try to reconnect after a delay
          Future.delayed(Duration(seconds: 5), () {
            if (mounted) {
              _webSocketService.connectToRealtimeUpdates(allSymbols);
            }
          });
        },
      );

      print('🎧 [HOME] Stream listener setup complete, subscription active: ${_realTimeSubscription != null}');
    }
  }

  void _handleRealTimeUpdate(RealTimeUpdate update) {
    if (!mounted) return;

    print('🔄 Processing update for ${update.symbol}: Price=${update.currentPrice}, Confidence=${update.confidence}');

    // Process updates with any valid data (not just confidence)
    if (update.currentPrice != null || update.confidence != null || update.predictedRange != null) {
      _pendingUpdates[update.symbol] = update;

      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 100), () {
        if (!mounted) return;

        print('🎯 Applying ${_pendingUpdates.length} pending updates to UI');

        setState(() {
          _pendingUpdates.forEach((symbol, update) {
            _isUpdating[symbol] = true;
            _updateAssetData(update);
            print(
                '✅ UI updated for ${update.symbol}: Price=\$${update.currentPrice?.toStringAsFixed(2) ?? 'N/A'}, Confidence=${update.confidence ?? 0}%, Range=${update.predictedRange ?? 'N/A'}');
          });
          _pendingUpdates.clear();
        });

        Future.delayed(Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _isUpdating.clear();
            });
          }
        });
      });
    } else {
      print('⚠️ Skipping update for ${update.symbol} - no valid data');
    }
  }

  void _updateAssetData(RealTimeUpdate update) {
    // Update all assets list
    for (int i = 0; i < _allAssets.length; i++) {
      if (_allAssets[i].symbol == update.symbol) {
        _allAssets[i] = _createUpdatedAsset(_allAssets[i], update);
        break;
      }
    }

    // Update crypto assets list
    for (int i = 0; i < _cryptoAssets.length; i++) {
      if (_cryptoAssets[i].symbol == update.symbol) {
        _cryptoAssets[i] = _createUpdatedAsset(_cryptoAssets[i], update);
        break;
      }
    }

    // Update stock assets list
    for (int i = 0; i < _stockAssets.length; i++) {
      if (_stockAssets[i].symbol == update.symbol) {
        _stockAssets[i] = _createUpdatedAsset(_stockAssets[i], update);
        break;
      }
    }

    // Update macro assets list
    for (int i = 0; i < _macroAssets.length; i++) {
      if (_macroAssets[i].symbol == update.symbol) {
        _macroAssets[i] = _createUpdatedAsset(_macroAssets[i], update);
        break;
      }
    }
  }

  MarketSummary _createUpdatedAsset(MarketSummary original, RealTimeUpdate update) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColors.kprimary,
                    child: Image.asset(AppImages.user),
                  ),
                  8.horizontalSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome!', style: AppTextStyles.kswhite12500),
                      Text(
                        'Hi Umar!',
                        style: AppTextStyles.kblack18500.copyWith(
                          color: AppColors.kwhite,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.ktertiary,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: SvgPicture.asset(
                      AppImages.notification,
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                ],
              ),
              23.verticalSpace,

              // Horizontal Tabs Section
              SizedBox(
                height: 31.h,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedTabIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 4.w),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.kprimary
                              : AppColors.ktertiary,
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                        child: Center(
                          child: Text(
                            _tabs[index],
                            style: AppTextStyles.ktblack13400.copyWith(
                              color: isSelected
                                  ? AppColors.kblack
                                  : AppColors.kwhite,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              8.verticalSpace,

              // Content based on selected tab
              _buildTabContent(),
              100.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // All
        return _buildAllContent();
      case 1: // Stocks
        return _buildStocksContent();
      case 2: // Crypto
        return _buildCryptoContent();
      case 3: // Macro
        return _buildMacroContent();
      case 4: // Favorites
        return _buildFavoritesContent();
      default:
        return _buildAllContent();
    }
  }

  Widget _buildAllContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.kprimary));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trending Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trending',
              style: AppTextStyles.kblack16500.copyWith(
                color: AppColors.kwhite,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'see all',
                    style: AppTextStyles.kblack14500.copyWith(
                      color: AppColors.kprimary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.kprimary,
                    ),
                  ),
                  4.horizontalSpace,
                  SvgPicture.asset(AppImages.arrow, width: 18.w, height: 18.h),
                ],
              ),
            ),
          ],
        ),

        8.verticalSpace,

        // Trending Items (Top performing assets from all categories)
        if (_allAssets.isNotEmpty)
          ..._allAssets.take(3).map((asset) => _buildAssetItem(asset)),

        23.verticalSpace,

        // Market Summary Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Market Summary',
              style: AppTextStyles.kblack16500.copyWith(
                color: AppColors.kwhite,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'see all',
                    style: AppTextStyles.kblack14500.copyWith(
                      color: AppColors.kprimary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.kprimary,
                    ),
                  ),
                  4.horizontalSpace,
                  SvgPicture.asset(AppImages.arrow, width: 18.w, height: 18.h),
                ],
              ),
            ),
          ],
        ),

        8.verticalSpace,

        // Market Summary Items (All assets)
        if (_allAssets.isNotEmpty)
          ..._allAssets.map((asset) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildAssetItem(asset),
          )),
      ],
    );
  }

  Widget _buildStocksContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.kprimary));
    }

    return Column(
      children: [
        if (_stockAssets.isNotEmpty)
          ..._stockAssets.map((asset) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildAssetItem(asset),
          )),
      ],
    );
  }

  Widget _buildCryptoContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.kprimary));
    }

    return Column(
      children: [
        if (_cryptoAssets.isNotEmpty)
          ..._cryptoAssets.map((asset) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildAssetItem(asset),
          )),
      ],
    );
  }

  Widget _buildMacroContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.kprimary));
    }

    return Column(
      children: [
        if (_macroAssets.isNotEmpty)
          ..._macroAssets.map((asset) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildAssetItem(asset),
          )),
      ],
    );
  }

  Widget _buildFavoritesContent() {
    // For now, show a subset of assets as favorites (this would typically come from user preferences)
    final favoriteAssets = [
      ..._cryptoAssets.take(2),
      ..._stockAssets.take(2),
      ..._macroAssets.take(1),
    ];

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.kprimary));
    }

    return Column(
      children: [
        if (favoriteAssets.isNotEmpty)
          ...favoriteAssets.map((asset) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildAssetItem(asset),
          )),
      ],
    );
  }

  Widget _buildAssetItem(MarketSummary asset) {
    // Get asset icon based on symbol
    String? iconPath = _getAssetIcon(asset.symbol);

    // Check if this asset is currently being updated
    bool isUpdating = _isUpdating[asset.symbol] ?? false;

    return buildTrendingItem(
      iconPath,
      asset.symbol,
      asset.name,
      '${asset.confidence.toString()}%',
      asset.forecastDirection.toLowerCase() == 'up',
      asset.predictedRange,
      isUpdating: isUpdating,
    );
  }

  String? _getAssetIcon(String symbol) {
    switch (symbol) {
      case 'BTC':
        return AppImages.btc;
      case 'ETH':
        return AppImages.eth;
      default:
        return null;
    }
  }


  String _formatPrice(double price) {
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

  String _formatPredictedRange(String? range) {
    if (range == null || range.isEmpty) return '-';

    try {
      final parts = range.split('–'); // split by en dash
      if (parts.length != 2) return range;

      final start = double.tryParse(parts[0].replaceAll(',', '').replaceAll('\$', ''));
      final end = double.tryParse(parts[1].replaceAll(',', '').replaceAll('\$', ''));

      if (start == null || end == null) return range;

      return '${_formatPrice(start)}–${_formatPrice(end)}';
    } catch (e) {
      return range;
    }
  }

}
