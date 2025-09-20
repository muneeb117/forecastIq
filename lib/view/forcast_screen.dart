import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';
import '../core/constants/images.dart';
import '../widgets/item_widget.dart';
import '../services/trading_ai_service.dart';
import '../services/websocket_service.dart';
import '../models/market_data.dart';

class ForcastScreen extends StatefulWidget {
  const ForcastScreen({super.key});

  @override
  State<ForcastScreen> createState() => _ForcastScreenState();
}

class _ForcastScreenState extends State<ForcastScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final TradingAIService _tradingService = TradingAIService();
  late WebSocketService _webSocketService;
  StreamSubscription<RealTimeUpdate>? _realTimeSubscription;

  final List<String> _tabs = ['All', 'Stocks', 'Crypto', 'Macro', 'Favorites'];

  List<MarketSummary> _cryptoForecasts = [];
  List<MarketSummary> _stockForecasts = [];
  List<MarketSummary> _macroForecasts = [];
  List<MarketSummary> _allForecasts = [];
  List<MarketSummary> _favoriteForecasts = [];

  bool _isLoading = true;

  // Animation controllers for real-time update indicators
  Map<String, bool> _isUpdating = {};

  // Debouncing for frequent updates
  Timer? _debounceTimer;
  Map<String, RealTimeUpdate> _pendingUpdates = {};

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketManager().getConnection('shared');
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadForecastData();
  }

  Future<void> _loadForecastData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _tradingService.getMarketSummary(),
        _tradingService.getMarketSummary(assetClass: 'crypto', limit: 10),
        _tradingService.getMarketSummary(assetClass: 'stocks', limit: 10),
        _tradingService.getMarketSummary(assetClass: 'macro', limit: 5),
      ]);

      setState(() {
        _allForecasts = results[0];
        _cryptoForecasts = results[1];
        _stockForecasts = results[2];
        _macroForecasts = results[3];
        _favoriteForecasts = _allForecasts.take(4).toList();
        _isLoading = false;
      });

      // Apply cached updates if available
      _webSocketService.latestUpdates.forEach((symbol, update) {
        _updateForecastData(update);
      });

      _startRealTimeUpdates();
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading forecast data: $e');
    }
  }

  void _startRealTimeUpdates() {
    final allSymbols = _allForecasts.map((forecast) => forecast.symbol).toList();

    if (allSymbols.isNotEmpty) {
      print('🚀 [FORECAST] Starting real-time forecast updates for symbols: $allSymbols');
      print('📊 [FORECAST] Crypto symbols: ${_cryptoForecasts.map((a) => a.symbol).toList()}');
      print('📈 [FORECAST] Stock symbols: ${_stockForecasts.map((a) => a.symbol).toList()}');
      print('🌍 [FORECAST] Macro symbols: ${_macroForecasts.map((a) => a.symbol).toList()}');

      // Apply cached updates if available
      _webSocketService.latestUpdates.forEach((symbol, update) {
        _updateForecastData(update);
      });

      // Ensure WebSocket is connected or connect if needed
      if (!_webSocketService.isConnected) {
        print('🔗 [FORECAST] Connecting to WebSocket...');
        _webSocketService.connectToRealtimeUpdates(allSymbols);
      } else {
        print('✅ [FORECAST] WebSocket already connected, reusing connection');
      }

      // Always setup stream listener (even if connection exists)
      _realTimeSubscription?.cancel();
      _realTimeSubscription = _webSocketService.realTimeStream?.listen(
            (update) {
          print('📨 [FORECAST] Received WebSocket update for ${update.symbol}');
          _handleRealTimeUpdate(update);
        },
        onError: (error) {
          print('❌ [FORECAST] Real-time forecast update error: $error');
          Future.delayed(Duration(seconds: 5), () {
            if (mounted) {
              _webSocketService.connectToRealtimeUpdates(allSymbols);
            }
          });
        },
      );

      print('🎧 [FORECAST] Stream listener setup complete');
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
            _updateForecastData(update);
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

  void _updateForecastData(RealTimeUpdate update) {
    print(
        'Updating forecast for ${update.symbol}: Price=${update.currentPrice}, Confidence=${update.confidence}, PredictedRange=${update.predictedRange}');


    for (int i = 0; i < _allForecasts.length; i++) {
      if (_allForecasts[i].symbol == update.symbol) {
        _allForecasts[i] = _createUpdatedForecast(_allForecasts[i], update);
        print(
            'Updated _allForecasts[${update.symbol}]: Confidence=${_allForecasts[i].confidence}, PredictedRange=${_allForecasts[i].predictedRange}');
        break;
      }
    }


    for (int i = 0; i < _cryptoForecasts.length; i++) {
      if (_cryptoForecasts[i].symbol == update.symbol) {
        _cryptoForecasts[i] = _createUpdatedForecast(_cryptoForecasts[i], update);
        print(
            'Updated _cryptoForecasts[${update.symbol}]: Confidence=${_cryptoForecasts[i].confidence}, PredictedRange=${_cryptoForecasts[i].predictedRange}');
        break;
      }
    }

    for (int i = 0; i < _stockForecasts.length; i++) {
      if (_stockForecasts[i].symbol == update.symbol) {
        _stockForecasts[i] = _createUpdatedForecast(_stockForecasts[i], update);
        print(
            'Updated _stockForecasts[${update.symbol}]: Confidence=${_stockForecasts[i].confidence}, PredictedRange=${_stockForecasts[i].predictedRange}');
        break;
      }
    }

    for (int i = 0; i < _macroForecasts.length; i++) {
      if (_macroForecasts[i].symbol == update.symbol) {
        _macroForecasts[i] = _createUpdatedForecast(_macroForecasts[i], update);
        print(
            'Updated _macroForecasts[${update.symbol}]: Confidence=${_macroForecasts[i].confidence}, PredictedRange=${_macroForecasts[i].predictedRange}');
        break;
      }
    }

    for (int i = 0; i < _favoriteForecasts.length; i++) {
      if (_favoriteForecasts[i].symbol == update.symbol) {
        _favoriteForecasts[i] = _createUpdatedForecast(_favoriteForecasts[i], update);
        print(
            'Updated _favoriteForecasts[${update.symbol}]: Confidence=${_favoriteForecasts[i].confidence}, PredictedRange=${_favoriteForecasts[i].predictedRange}');
        break;
      }
    }
  }

  MarketSummary _createUpdatedForecast(MarketSummary original, RealTimeUpdate update) {
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
  void dispose() {
    _debounceTimer?.cancel();
    _realTimeSubscription?.cancel();
    _searchController.dispose();
    // Do not dispose WebSocketService to persist connection
    super.dispose();
  }

  String? _getImageForSymbol(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return AppImages.btc;
      case 'ETH':
        return AppImages.eth;
      default:
        return null;
    }
  }

  String _formatPrice(double? price) {
    if (price == null) return '-';
    if (price >= 1000000) {
      double millions = price / 1000000;
      return millions == millions.roundToDouble()
          ? '\$${millions.round()}M'
          : '\$${millions.toStringAsFixed(2)}M';
    } else if (price >= 1000) {
      double thousands = price / 1000;
      return thousands == thousands.roundToDouble()
          ? '\$${thousands.round()}k'
          : '\$${thousands.toStringAsFixed(2)}k';
    } else if (price < 1) {
      return '\$${price.toStringAsFixed(4)}';
    } else {
      return '\$${price.toStringAsFixed(2)}';
    }
  }

  String _formatPredictedRange(String? range) {
    if (range == null || range.isEmpty) return '-';

    try {
      final parts = range.split('–');
      if (parts.length != 2) return range;

      final start = double.tryParse(parts[0].replaceAll(',', '').replaceAll('\$', ''));
      final end = double.tryParse(parts[1].replaceAll(',', '').replaceAll('\$', ''));

      if (start == null || end == null) return range;

      return '${_formatPrice(start)}–${_formatPrice(end)}';
    } catch (e) {
      return range;
    }
  }

  Widget _buildForecastContent(List<MarketSummary> forecasts) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.kprimary),
      );
    }

    if (forecasts.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: AppTextStyles.kblack16500.copyWith(color: AppColors.kwhite2),
        ),
      );
    }

    List<MarketSummary> filteredForecasts = forecasts.where((forecast) {
      if (_searchQuery.isEmpty) return true;
      return forecast.symbol.toLowerCase().contains(_searchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...filteredForecasts.map((forecast) => Column(
          children: [
            buildTrendingItem(
              _getImageForSymbol(forecast.symbol),
              forecast.symbol,
              forecast.name,
              '${forecast.confidence?.toString() ?? '-'}%',
              forecast.forecastDirection.toLowerCase() == 'up',
              _formatPredictedRange(forecast.predictedRange),
              isUpdating: _isUpdating[forecast.symbol] ?? false,
            ),
            SizedBox(height: 12.h),
          ],
        )).toList(),
      ],
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
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome!', style: AppTextStyles.kswhite12500),
                      Text(
                        'Forcast',
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 54.h,
                      decoration: BoxDecoration(
                        color: AppColors.ktertiary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: AppTextStyles.kblack14500.copyWith(
                          color: AppColors.kwhite,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Search ...',
                          hintStyle: AppTextStyles.kblack14500.copyWith(
                            color: AppColors.kwhite2,
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 20.w, right: 12.w),
                            child: SvgPicture.asset(
                              AppImages.search,
                              width: 18.w,
                              height: 18.h,
                              color: AppColors.kwhite,
                              fit: BoxFit.contain,
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 18.w,
                            minHeight: 18.h,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                      ),
                    ),
                  ),
                  8.horizontalSpace,
                  GestureDetector(
                    onTap: () {
                      // Implement filter or other action
                    },
                    child: Container(
                      height: 54.h,
                      width: 54.w,
                      decoration: BoxDecoration(
                        color: AppColors.ktertiary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppImages.filter,
                          width: 24.w,
                          height: 24.h,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              8.verticalSpace,
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
                          color: isSelected ? AppColors.kprimary : AppColors.ktertiary,
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                        child: Center(
                          child: Text(
                            _tabs[index],
                            style: AppTextStyles.ktblack13400.copyWith(
                              color: isSelected ? AppColors.kblack : AppColors.kwhite,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              23.verticalSpace,
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
    return _buildForecastContent(_allForecasts);
  }

  Widget _buildStocksContent() {
    return _buildForecastContent(_stockForecasts);
  }

  Widget _buildCryptoContent() {
    return _buildForecastContent(_cryptoForecasts);
  }

  Widget _buildMacroContent() {
    return _buildForecastContent(_macroForecasts);
  }

  Widget _buildFavoritesContent() {
    return _buildForecastContent(_favoriteForecasts);
  }
}