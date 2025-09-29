import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'dart:async';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/images.dart';
import '../../models/models.dart';
import '../../services/favorites_service.dart';
import '../../services/websocket_service.dart';


class CoinDetailScreen extends StatefulWidget {
  final String? image;
  final String symbol;
  final String name;
  final String percentage;
  final bool isUp;
  final String price;

  const CoinDetailScreen({
    super.key,
    this.image,
    required this.symbol,
    required this.name,
    required this.percentage,
    required this.isUp,
    required this.price,
  });

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  int _selectedTimeFrame = 2; // Default to 1d
  final List<String> _timeFrames = ['1h', '4h', '1d', '7d', '1M'];

  // Shared WebSocket service
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription? _chartSubscription;
  final FavoritesService _favoritesService = FavoritesService.instance;

  ChartData? _chartData;
  ChartUpdate? _latestChartUpdate;
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Current data for display
  String _currentPrice = '\$0.00';
  String _confidence = '0%';
  String _predictedRange = '--';
  String _forecastDirection = 'HOLD';
  DateTime? _lastUpdated;

  Timer? _timeoutTimer;

  // Favorites functionality
  bool _isFavorite = false;

  // Screenshot functionality
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _initializeFavorites();
    _initializeChartData();
  }

  void _initializeFavorites() async {
    await _favoritesService.init();
    setState(() {
      _isFavorite = _favoritesService.isFavorite(widget.symbol);
    });
  }

  void _toggleFavorite() async {
    final itemType = FavoritesService.determineItemType(widget.symbol);
    await _favoritesService.toggleFavorite(
      symbol: widget.symbol,
      name: widget.name,
      image: widget.image,
      type: itemType,
    );


    setState(() {
      _isFavorite = _favoritesService.isFavorite(widget.symbol);
    });

    // Show feedback to user
    final message = _isFavorite
        ? '${widget.symbol} added to favorites'
        : '${widget.symbol} removed from favorites';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: _isFavorite ? AppColors.kgreen : AppColors.kred,
      ),
    );
  }



  @override
  void dispose() {
    _chartSubscription?.cancel();
    _webSocketService.disconnect();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _initializeChartData() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    final selectedTimeframe = _timeFrames[_selectedTimeFrame];
    final apiTimeframe = _getApiTimeframe(selectedTimeframe);

    print('🔗 Connecting to WebSocket via WebSocketService:');
    print('   Selected: $selectedTimeframe -> API: $apiTimeframe');
    print('   Symbol: ${widget.symbol}');

    // Cancel existing subscription
    _chartSubscription?.cancel();

    // Set timeout
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(Duration(seconds: 15), () {
      if (_isLoading && mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Connection timeout. Please check your internet connection.';
        });
        print('⏰ WebSocket connection timeout');
      }
    });

    try {
      // Use shared WebSocket service for chart data
      _webSocketService.connectToAssetChart(widget.symbol, timeframe: apiTimeframe).then((_) {
        if (_webSocketService.chartStream != null) {
          _chartSubscription = _webSocketService.chartStream!.listen(
            (chartUpdate) {
              _timeoutTimer?.cancel();
              print('📡 Received chart update via WebSocketService');
              _handleChartUpdate(chartUpdate);
            },
            onError: (error) {
              _timeoutTimer?.cancel();
              print('❌ WebSocket error: $error');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  _errorMessage = 'Connection failed: $error';
                });
              }
            },
            onDone: () {
              _timeoutTimer?.cancel();
              print('🔚 WebSocket connection closed');
              if (mounted && _isLoading) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  _errorMessage = 'Connection closed unexpectedly';
                });
              }
            },
          );
        }
      }).catchError((e) {
        _timeoutTimer?.cancel();
        print('❌ Failed to connect: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Failed to establish connection: $e';
          });
        }
      });
    } catch (e) {
      _timeoutTimer?.cancel();
      print('❌ Failed to connect: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to establish connection: $e';
      });
    }
  }

  void _handleChartUpdate(ChartUpdate chartUpdate) {
    if (!mounted) return;

    try {
      final currentTimeframe = _timeFrames[_selectedTimeFrame];

      print('✅ Successfully received ChartUpdate for ${chartUpdate.symbol}');
      print('📈 Timeframe: $currentTimeframe (Expected vs Received: ${chartUpdate.timeframe})');
      print('📈 Past prices count: ${chartUpdate.chartData.pastPrices.length}');
      print('🔮 Future prices count: ${chartUpdate.chartData.futurePrices.length}');

      // Validate data points based on timeframe
      _validateTimeframeData(currentTimeframe, chartUpdate.chartData);

      // Validate that we have data
      bool hasValidData = chartUpdate.chartData.pastPrices.isNotEmpty ||
          chartUpdate.chartData.futurePrices.isNotEmpty;

      if (hasValidData) {
        setState(() {
          _latestChartUpdate = chartUpdate;
          _chartData = chartUpdate.chartData;
          _isLoading = false;
          _hasError = false;
          _errorMessage = '';
          _isUpdating = true;

          // Update display data
          _currentPrice = '\$${chartUpdate.currentPrice.toStringAsFixed(2)}';
          _confidence = '${chartUpdate.confidence}%';
          _predictedRange = chartUpdate.predictedRange;
          _forecastDirection = chartUpdate.forecastDirection;
          _lastUpdated = chartUpdate.lastUpdated;
        });

        // Clear updating indicator
        Future.delayed(Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _isUpdating = false;
            });
          }
        });

        print('🎉 Chart updated successfully!');
      } else {
        print('⚠️ Received chart update but no price data');
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'No chart data available for this timeframe';
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error handling chart update: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to process chart data';
      });
    }
  }

  void _onTimeFrameChanged(int index) {
    if (_selectedTimeFrame == index) return;

    setState(() {
      _selectedTimeFrame = index;
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    _connectToWebSocket();
  }

  void _validateTimeframeData(String timeframe, ChartData chartData) {
    print('🔍 Validating data for timeframe: $timeframe');

    // Expected data points for each timeframe
    Map<String, Map<String, int>> expectedDataPoints = {
      '1h': {'past': 24, 'future': 12},  // 24 past hours + 12 future hours (1 point per hour)
      '4h': {'past': 24, 'future': 12},  // 24 past 4h periods + 12 future 4h periods (1 point per 4h)
      '1d': {'past': 30, 'future': 15},  // 30 past days + 15 future days (1 point per day)
      '7d': {'past': 12, 'future': 6},   // 12 past weeks + 6 future weeks (1 point per week)
      '1M': {'past': 12, 'future': 6},   // 12 past months + 6 future months (1 point per month)
    };

    final expected = expectedDataPoints[timeframe];
    if (expected != null) {
      final actualPast = chartData.pastPrices.length;
      final actualFuture = chartData.futurePrices.length;
      final expectedPast = expected['past']!;
      final expectedFuture = expected['future']!;

      print('📊 Expected: Past=${expectedPast}, Future=${expectedFuture}');
      print('📊 Actual: Past=${actualPast}, Future=${actualFuture}');

      if (actualPast != expectedPast) {
        print('⚠️ Past data mismatch! Expected $expectedPast but got $actualPast');
      }
      if (actualFuture != expectedFuture) {
        print('⚠️ Future data mismatch! Expected $expectedFuture but got $actualFuture');
      }

      // Log data granularity info based on timeframe
      switch (timeframe) {
        case '1h':
          print('💡 1h Timeframe should show:');
          print('   - Past: Last 24 hours (1 point per hour)');
          print('   - Future: Next 12 hours (1 point per hour)');
          break;
        case '4h':
          print('💡 4h Timeframe should show:');
          print('   - Past: Last 96 hours in 4h intervals (1 point per 4h)');
          print('   - Future: Next 48 hours in 4h intervals (1 point per 4h)');
          break;
        case '1d':
          print('💡 1d Timeframe should show:');
          print('   - Past: Last 30 days (1 point per day)');
          print('   - Future: Next 15 days (1 point per day)');
          break;
        case '7d':
          print('💡 7d Timeframe should show:');
          print('   - Past: Last 12 weeks (1 point per week)');
          print('   - Future: Next 6 weeks (1 point per week)');
          break;
        case '1M':
          print('💡 1M Timeframe should show:');
          print('   - Past: Last 12 months (1 point per month)');
          print('   - Future: Next 6 months (1 point per month)');
          break;
      }
    }
  }

  String _getApiTimeframe(String uiTimeframe) {
    // Map UI timeframes to API timeframes (backend expects uppercase)
    switch (uiTimeframe) {
      case '1h': return '1H';   // 1 Hour view uses 1 Hour granularity
      case '4h': return '4H';   // 4 Hour view uses 4 Hour granularity
      case '1d': return '1D';   // 1 Day view uses 1 Day granularity
      case '7d': return '7D';   // 7 Day view uses 7 Day granularity
      case '1M': return '1M';   // 1 Month view uses 1 Month granularity
      default: return '1D';     // Default fallback to 1 day
    }
  }

  void _refreshChart() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    _connectToWebSocket();
  }

  Future<void> _saveChartToGallery() async {
    try {
      // Check if chart data is available
      if (_isLoading || _hasError || _chartData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chart not ready. Please wait for chart to load.'),
            backgroundColor: AppColors.kred,
          ),
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
      final Uint8List? image = await _screenshotController.capture();

      if (image != null) {
        // Get temporary directory
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = '${widget.symbol}_chart_${DateTime.now().millisecondsSinceEpoch}.png';
        final File imageFile = File('${tempDir.path}/$fileName');

        // Write image to file
        await imageFile.writeAsBytes(image);

        // Save to gallery
        await Gal.putImage(imageFile.path, album: 'ForcastIQ Charts');

        // Clean up temporary file
        await imageFile.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chart saved to gallery successfully!'),
            backgroundColor: AppColors.kgreen,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to capture chart');
      }
    } catch (e) {
      print('Error saving chart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save chart: ${e.toString()}'),
          backgroundColor: AppColors.kred,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatPrice(double price) {
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

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  double get _minPrice {
    if (_chartData == null) return 0;
    final allPrices = [..._chartData!.pastPrices, ..._chartData!.futurePrices];
    return allPrices.isEmpty ? 0 : allPrices.reduce((a, b) => a < b ? a : b);
  }

  double get _maxPrice {
    if (_chartData == null) return 100;
    final allPrices = [..._chartData!.pastPrices, ..._chartData!.futurePrices];
    return allPrices.isEmpty ? 100 : allPrices.reduce((a, b) => a > b ? a : b);
  }

  bool get _isUpTrend {
    final direction = _forecastDirection.toUpperCase();
    return direction == 'UP' || direction == 'HOLD';
  }

  Widget _buildChartWidget() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.kprimary),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Loading chart data...',
              style: AppTextStyles.ktwhite12500.copyWith(
                color: AppColors.kwhite.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.kred,
              size: 24.w,
            ),
            SizedBox(height: 8.h),
            Text(
              _errorMessage.isNotEmpty ? _errorMessage : 'Failed to load chart',
              style: AppTextStyles.ktwhite12500.copyWith(
                color: AppColors.kred,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: _refreshChart,
              child: Text(
                'Tap to retry',
                style: AppTextStyles.ktwhite12500.copyWith(
                  color: AppColors.kprimary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_chartData == null ||
        (_chartData!.pastPrices.isEmpty && _chartData!.futurePrices.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              color: AppColors.kwhite.withValues(alpha: 0.4),
              size: 24.w,
            ),
            SizedBox(height: 8.h),
            Text(
              'No chart data available',
              style: AppTextStyles.ktwhite14400.copyWith(
                color: AppColors.kwhite.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return CustomPaint(
      painter: ChartPainter(
        chartData: _chartData!,
        isUp: _isUpTrend,
        selectedTimeframe: _timeFrames[_selectedTimeFrame],
      ),
      size: Size(double.infinity, 120.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () => Get.back(),
                        child: SvgPicture.asset(
                          AppImages.left,
                          width: 24.w,
                          height: 24.h,
                        )
                    ),
                    Text(
                      widget.name,
                      style: AppTextStyles.ktwhite16600,
                    ),
                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: SvgPicture.asset(
                        _isFavorite ? AppImages.favourite : AppImages.heart,
                        width: 24.w,
                        height: 24.h,
                        colorFilter: _isFavorite
                          ? ColorFilter.mode(AppColors.kred, BlendMode.srcIn)
                          : null,
                      ),
                    )
                  ],
                ),
              ),
              21.verticalSpace,

              Column(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: widget.image == null ? AppColors.kprimary : Colors.transparent,
                    child: widget.image != null
                        ? Image.asset(
                      widget.image!,
                      width: 60.w,
                      height: 60.h,
                    )
                        : Text(
                      widget.symbol.substring(0, 1),
                      style: AppTextStyles.ktwhite16600.copyWith(
                        color: AppColors.kwhite,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  46.verticalSpace,

                  // Percentage Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: widget.isUp
                          ? AppColors.kgreen.withValues(alpha: 0.16)
                          : AppColors.kred.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          widget.isUp ? AppImages.arrowup : AppImages.arrowdown,
                          width: 24.w,
                          height: 16.h,
                        ),
                        4.horizontalSpace,
                        Text(
                        _confidence,
                          style: AppTextStyles.ktwhite14500.copyWith(
                            color: widget.isUp ? AppColors.kgreen : AppColors.kred,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              21.verticalSpace,

              // Chart Section
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.ksecondary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  color: AppColors.kwhite.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Past',
                                style: AppTextStyles.ktwhite16400,
                              ),
                            ],
                          ),
                          SizedBox(width: 24.w),
                          Row(
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  color: AppColors.kprimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Future',
                                style: AppTextStyles.ktwhite16400,
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Price Labels
                      if (_chartData != null && !_isLoading && !_hasError)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatPrice(_minPrice),
                              style: AppTextStyles.ktwhite12500.copyWith(
                                color: AppColors.kred,
                              ),
                            ),
                            Text(
                              _formatPrice(_maxPrice),
                              style: AppTextStyles.ktwhite12500.copyWith(
                                color: AppColors.kgreen,
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 16.h),

                      // Chart Container
                      Container(
                        height: 120.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: _buildChartWidget(),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Time Frame Buttons
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _timeFrames.asMap().entries.map((entry) {
                    int index = entry.key;
                    String timeFrame = entry.value;
                    bool isSelected = _selectedTimeFrame == index;

                    return GestureDetector(
                      onTap: () => _onTimeFrameChanged(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.kprimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          timeFrame,
                          style: AppTextStyles.ktwhite14500.copyWith(
                            color: isSelected ? AppColors.kwhite : AppColors.kwhite,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 16.h),

              // Save and Refresh Buttons
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _saveChartToGallery,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: AppColors.ktertiary,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.ktertiary,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(AppImages.save,
                              width: 18.w,
                              height: 18.h,
                            ),
                            SizedBox(width: 7.19.w),
                            Text(
                              'Save',
                              style: AppTextStyles.ktwhite14400,
                            ),
                          ],
                        ),
                      ),
                    ),
                    8.horizontalSpace,
                    GestureDetector(
                      onTap: _refreshChart,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: AppColors.ktertiary,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.ktertiary,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(AppImages.rotate,
                              width: 18.w,
                              height: 18.h,
                            ),
                            SizedBox(width: 7.19.w),
                            Text(
                              'Refresh',
                              style: AppTextStyles.ktwhite14400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              21.verticalSpace,

              // Forecast Details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    // Forecast Direction and Confidence Score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Forecast Direction',
                                style: AppTextStyles.ktwhite14500.copyWith(
                                  color: AppColors.kwhite2,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    _isUpTrend ? AppImages.arrowup : AppImages.arrowdown,
                                    width: 24.w,
                                    height: 24.h,
                                  ),
                                  4.horizontalSpace,
                                  Text(
                                    _forecastDirection.toUpperCase(),
                                    style: AppTextStyles.kwhite16700.copyWith(
                                      color: _isUpTrend ? AppColors.kgreen : AppColors.kred,
                                    ),
                                  ),

                                  16.horizontalSpace,
                                  SvgPicture.asset(
                                    _isUpTrend ? AppImages.forcastup : AppImages.forcastdown,
                                    width: 74.w,
                                    height: 56.h,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Confidence Score',
                              style: AppTextStyles.ktwhite14500.copyWith(
                                color: AppColors.kwhite2,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                color: widget.isUp ? AppColors.kgreen.withValues(alpha: 0.16) : AppColors.kred.withValues(alpha: 0.16),
                              ),
                              child: Text(
                                _confidence,
                                style: AppTextStyles.kwhite16700.copyWith(
                                  color: _isUpTrend ? AppColors.kgreen : AppColors.kred,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Predicted and Last Updated
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Predicted',
                                style: AppTextStyles.ktwhite14500.copyWith(
                                  color: AppColors.kwhite2,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _predictedRange,
                                style: AppTextStyles.ktwhite14600,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Last Updated',
                                style: AppTextStyles.ktwhite14500.copyWith(
                                  color: AppColors.kwhite2,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _lastUpdated != null
                                    ? '${_lastUpdated!.day} ${_getMonthName(_lastUpdated!.month)} ${_lastUpdated!.year} | ${_lastUpdated!.hour.toString().padLeft(2, '0')}:${_lastUpdated!.minute.toString().padLeft(2, '0')}'
                                    : 'No updates yet',
                                style: AppTextStyles.ktwhite14600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              GestureDetector(
                onTap: _refreshChart,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(100.r),
                    border: Border.all(
                      color: AppColors.kwhite.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppImages.rotate,
                        width: 24.w,
                        height: 24.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Refresh',
                        style: AppTextStyles.ktwhite14500,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final ChartData chartData;
  final bool isUp;
  final String selectedTimeframe;

  ChartPainter({
    required this.chartData,
    required this.isUp,
    required this.selectedTimeframe,
  });

  @override
  void paint(Canvas canvas, Size size) {
    print('Painting chart: pastPrices=${chartData.pastPrices.length}, futurePrices=${chartData.futurePrices.length}');

    // Past data (grey line)
    final pastPaint = Paint()
      ..color = Colors.grey.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Future data (green or red line based on trend)
    final futurePaint = Paint()
      ..color = isUp ? AppColors.kgreen : AppColors.kred
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Calculate min and max prices for scaling
    final allPrices = [...chartData.pastPrices, ...chartData.futurePrices];
    final minPrice = allPrices.isEmpty ? 0.0 : allPrices.reduce((a, b) => a < b ? a : b);
    final maxPrice = allPrices.isEmpty ? 100.0 : allPrices.reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    // Avoid division by zero
    if (priceRange == 0) {
      print('Price range is zero, skipping chart rendering');
      return;
    }

    // Create paths for past and future data
    final pastPath = Path();
    final futurePath = Path();

    // Scale data points to fit canvas properly
    final totalPoints = chartData.pastPrices.length + chartData.futurePrices.length;
    final xStep = totalPoints > 1 ? size.width / (totalPoints - 1) : 0;

    // Past data points with cubic smoothing
    if (chartData.pastPrices.isNotEmpty) {
      pastPath.moveTo(0, _scaleY(chartData.pastPrices[0], minPrice, priceRange, size.height));
      for (int i = 0; i < chartData.pastPrices.length - 1; i++) {
        final x1 = i * xStep;
        final y1 = _scaleY(chartData.pastPrices[i], minPrice, priceRange, size.height);
        final x2 = (i + 1) * xStep;
        final y2 = _scaleY(chartData.pastPrices[i + 1], minPrice, priceRange, size.height);

        // Cubic curve control points
        final controlPoint1 = Offset(x1 + xStep * 0.4, y1);
        final controlPoint2 = Offset(x2 - xStep * 0.4, y2);
        pastPath.cubicTo(
          controlPoint1.dx.toDouble(),
          controlPoint1.dy.toDouble(),
          controlPoint2.dx.toDouble(),
          controlPoint2.dy.toDouble(),
          x2.toDouble(),
          y2.toDouble(),
        );
      }
    }

    // Future data points with cubic smoothing
    if (chartData.futurePrices.isNotEmpty) {
      final pastLength = chartData.pastPrices.length;
      final startY = chartData.pastPrices.isNotEmpty
          ? chartData.pastPrices.last
          : chartData.futurePrices[0];
      futurePath.moveTo(
        ((pastLength - 1) * xStep).toDouble(),
        _scaleY(startY, minPrice, priceRange, size.height),
      );
      for (int i = 0; i < chartData.futurePrices.length - 1; i++) {
        final x1 = (pastLength + i) * xStep;
        final y1 = _scaleY(chartData.futurePrices[i], minPrice, priceRange, size.height);
        final x2 = (pastLength + i + 1) * xStep;
        final y2 = _scaleY(chartData.futurePrices[i + 1], minPrice, priceRange, size.height);

        // Cubic curve control points
        final controlPoint1 = Offset(x1 + xStep * 0.4, y1);
        final controlPoint2 = Offset(x2 - xStep * 0.4, y2);
        futurePath.cubicTo(
          controlPoint1.dx.toDouble(),
          controlPoint1.dy.toDouble(),
          controlPoint2.dx.toDouble(),
          controlPoint2.dy.toDouble(),
          x2.toDouble(),
          y2.toDouble(),
        );
      }
    }

    // Draw the paths
    canvas.drawPath(pastPath, pastPaint);
    canvas.drawPath(futurePath, futurePaint);

    // Paint styles for price dots and text
    final pastDotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey.withOpacity(0.8);

    final futureDotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUp ? AppColors.kgreen : AppColors.kred;

    // Text style for price labels
    final textStyle = TextStyle(
      color: AppColors.kwhite.withOpacity(0.7),
      fontSize: 8.0,
      fontWeight: FontWeight.w500,
    );

    // Show all data points with price labels

    // Draw price dots and labels for past data - SHOW EVERY ALTERNATE POINT
    if (chartData.pastPrices.isNotEmpty) {
      for (int i = 0; i < chartData.pastPrices.length; i++) {
        final x = i * xStep;
        final y = _scaleY(chartData.pastPrices[i], minPrice, priceRange, size.height);

        // Draw dot for all points
        canvas.drawCircle(Offset(x.toDouble(), y), 2.5, pastDotPaint);

        // Show price labels only for: start point
        bool shouldShowLabel = i == 0; // Only start point (first)


        if (shouldShowLabel) {
          final price = chartData.pastPrices[i];
          final priceText = _formatPriceShort(price);
          final textSpan = TextSpan(text: priceText, style: textStyle);
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();

          // Position text above the dot with some padding
          final textX = x - textPainter.width / 2;
          final textY = y - textPainter.height - 8;

          // Smart positioning for selected price labels
          if (textX >= -10 && textX + textPainter.width <= size.width + 10) {
            final adjustedX = textX < 0 ? 0.0 : (textX + textPainter.width > size.width ? size.width - textPainter.width : textX);
            final adjustedY = textY < 0 ? 5.0 : textY;
            textPainter.paint(canvas, Offset(adjustedX, adjustedY));
          }
        }
      }
    }

    // Draw price dots and labels for future data (predictions)
    if (chartData.futurePrices.isNotEmpty) {
      final pastLength = chartData.pastPrices.length;

      // Enhanced text style for future prediction prices (more prominent)
      final futurePriceTextStyle = TextStyle(
        color: isUp ? AppColors.kgreen : AppColors.kred,
        fontSize: 9.0,
        fontWeight: FontWeight.w600,
      );

      // Show future prediction prices - EVERY ALTERNATE POINT for consistency
      for (int i = 0; i < chartData.futurePrices.length; i++) {
        final x = (pastLength + i) * xStep;
        final y = _scaleY(chartData.futurePrices[i], minPrice, priceRange, size.height);

        // Draw larger, more prominent dot for all future predictions
        canvas.drawCircle(Offset(x.toDouble(), y), 3.0, futureDotPaint);

        // Show price labels only for: start and end points
        bool shouldShowLabel = i == 0 || // Start point (first)
                              i == chartData.futurePrices.length - 1; // End point (last)


        if (shouldShowLabel) {
          final price = chartData.futurePrices[i];
          final priceText = _formatPriceShort(price);
          final textSpan = TextSpan(text: priceText, style: futurePriceTextStyle);
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();

          // Position text above the dot with some padding
          final textX = x - textPainter.width / 2;
          final textY = y - textPainter.height - 10;

          // Smart positioning for selected future prediction prices
          if (textX >= -10 && textX + textPainter.width <= size.width + 10) {
            final adjustedX = textX < 0 ? 0.0 : (textX + textPainter.width > size.width ? size.width - textPainter.width : textX);
            final adjustedY = textY < 0 ? 5.0 : textY;
            textPainter.paint(canvas, Offset(adjustedX, adjustedY));
          }
        }
      }
    }

    // Draw connection point dot (larger)
    if (chartData.pastPrices.isNotEmpty && chartData.futurePrices.isNotEmpty) {
      final connectionDotPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.kwhite;
      final connectionX = ((chartData.pastPrices.length - 1) * xStep).toDouble();
      final connectionY = _scaleY(chartData.pastPrices.last, minPrice, priceRange, size.height);
      canvas.drawCircle(Offset(connectionX, connectionY), 4.0, connectionDotPaint);
    }
  }

  double _scaleY(double price, double minPrice, double priceRange, double canvasHeight) {
    // Invert Y-axis (lower prices at bottom, higher at top)
    return canvasHeight - ((price - minPrice) / priceRange) * canvasHeight;
  }



  // Format price for short display on chart
  String _formatPriceShort(double price) {
    if (price >= 1000000) {
      return '\$${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(1)}K';
    } else if (price < 1) {
      return '\$${price.toStringAsFixed(3)}';
    } else {
      return '\$${price.toStringAsFixed(1)}';
    }
  }







  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

