import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'dart:async';
import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';
import '../services/trading_ai_service.dart';
import '../services/websocket_service.dart';
import '../models/market_data.dart';

class TrendScreen extends StatefulWidget {
  const TrendScreen({super.key});

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  bool showTrendHistory = false;
  String selectedTimeFilter = '1W';
  bool forecastVsActual = false;
  String selectedCoinSymbol = 'BTC';
  bool showDropdown = false;
  bool _isLoading = false;

  final TradingAIService _tradingService = TradingAIService();
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<RealTimeUpdate>? _realTimeSubscription;
  StreamSubscription<TrendsUpdate>? _trendsSubscription;
  AssetTrends? _currentTrends;

  // Real-time accuracy updates
  Map<String, double> _realTimeAccuracy = {};

  // Real-time trends data
  TrendsUpdate? _currentTrendsUpdate;
  List<Map<String, dynamic>> _realTimeTrendHistory = [];

  final List<String> timeFilters = ['1W', '7D', '1M', '1Y', '5Y'];

  final List<Map<String, dynamic>> availableCoins = [
    {
      'symbol': 'BTC',
      'name': 'Bitcoin',
      'image': AppImages.btc,
    },
    {
      'symbol': 'ETH',
      'name': 'Ethereum',
      'image': AppImages.eth,
    },
    {
      'symbol': 'NVDA',
      'name': 'NVIDIA',
      'image': null,
    },
    {
      'symbol': 'AAPL',
      'name': 'Apple Inc.',
      'image': null,
    },
    {
      'symbol': 'MSFT',
      'name': 'Microsoft',
      'image': null,
    },
    {
      'symbol': 'GDP',
      'name': 'GDP',
      'image': null,
    },
    {
      'symbol': 'CPI',
      'name': 'CPI (Inflation)',
      'image': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTrendData();
    _startRealTimeTrendsUpdates();
  }

  @override
  void dispose() {
    _realTimeSubscription?.cancel();
    _trendsSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }

  void _startRealTimeTrendsUpdates() {
    // Only connect if the symbol has trends endpoint available
    final availableTrendsSymbols = ['BTC', 'NVDA'];

    if (availableTrendsSymbols.contains(selectedCoinSymbol)) {
      print('🔗 Connecting to trends WebSocket for ${selectedCoinSymbol}');

      _webSocketService.connectToAssetTrends(selectedCoinSymbol);

      _trendsSubscription = _webSocketService.trendsStream?.listen(
        (trendsUpdate) {
          _handleTrendsUpdate(trendsUpdate);
        },
        onError: (error) {
          print('❌ Trends WebSocket error: $error');
          // Generate mock trends data for symbols without trends endpoints
          _generateMockTrendsData();
        },
      );
    } else {
      print('📊 No trends endpoint for ${selectedCoinSymbol}, using mock data');
      _generateMockTrendsData();
    }
  }

  void _generateMockTrendsData() {
    // Generate mock trends update for symbols without real endpoints
    final mockTrendsUpdate = TrendsUpdate(
      type: 'trends_update',
      symbol: selectedCoinSymbol,
      accuracy: double.parse(_getRealTimeAccuracy(selectedCoinSymbol).replaceAll('%', '')),
      chart: TrendsChart(
        forecast: [65.2, 68.1, 71.3, 69.8, 73.2],
        actual: [64.8, 67.9, 70.1, 69.5, 72.8],
        timestamps: ['09:00', '12:00', '15:00', '18:00', '21:00'],
      ),
      history: [
        TrendsHistory(date: 'Aug 1 2025', forecast: 'UP', actual: 'UP', result: 'HIT'),
        TrendsHistory(date: 'Aug 2 2025', forecast: 'UP', actual: 'DOWN', result: 'MISS'),
        TrendsHistory(date: 'Aug 3 2025', forecast: 'DOWN', actual: 'DOWN', result: 'HIT'),
      ],
      lastUpdated: DateTime.now(),
    );

    _handleTrendsUpdate(mockTrendsUpdate);
  }

  void _handleTrendsUpdate(TrendsUpdate trendsUpdate) {
    if (!mounted) return;

    print('📈 Received trends update: ${trendsUpdate.symbol} - Accuracy: ${trendsUpdate.accuracy}%');

    setState(() {
      _currentTrendsUpdate = trendsUpdate;

      // Update real-time accuracy
      _realTimeAccuracy[trendsUpdate.symbol] = trendsUpdate.accuracy;

      // Convert API history to UI format
      _realTimeTrendHistory = trendsUpdate.history.map((historyItem) {
        Color forecastColor = historyItem.forecast.toUpperCase() == 'UP' ? AppColors.kgreen : AppColors.kred;
        Color actualColor = historyItem.actual.toUpperCase() == 'UP' ? AppColors.kgreen : AppColors.kred;
        Color resultColor = historyItem.result.toUpperCase() == 'HIT' ? AppColors.kgreen : AppColors.kred;

        return {
          'date': historyItem.date,
          'forecast': historyItem.forecast.toLowerCase() == 'up' ? 'Up' : 'Down',
          'actual': historyItem.actual.toLowerCase() == 'up' ? 'Up' : 'Down',
          'result': historyItem.result.toLowerCase() == 'hit' ? 'Hit' : 'Miss',
          'forecastColor': forecastColor,
          'actualColor': actualColor,
          'resultColor': resultColor,
        };
      }).toList();
    });
  }

  Future<void> _loadTrendData() async {
    setState(() => _isLoading = true);

    try {
      final trends = await _tradingService.getAssetTrends(
        selectedCoinSymbol,
        timeframe: _getTimeframeForFilter(selectedTimeFilter)
      );

      setState(() {
        _currentTrends = trends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading trend data: $e');
    }
  }

  String _getTimeframeForFilter(String filter) {
    switch (filter) {
      case '1W':
        return '7D';
      case '7D':
        return '7D';
      case '1M':
        return '1M';
      case '1Y':
        return '1Y';
      case '5Y':
        return '5Y';
      default:
        return '7D';
    }
  }

  final List<Map<String, dynamic>> trendHistoryData = [
    {
      'date': 'Aug 1 2025',
      'forecast': 'Up',
      'actual': 'Up',
      'result': 'Hit',
      'forecastColor': AppColors.kgreen,
      'actualColor': AppColors.kgreen,
      'resultColor': AppColors.kgreen,
    },
    {
      'date': 'Aug 1 2025',
      'forecast': 'Up',
      'actual': 'Down',
      'result': 'Miss',
      'forecastColor': AppColors.kgreen,
      'actualColor': AppColors.kred,
      'resultColor': AppColors.kred,
    },
    {
      'date': 'Aug 1 2025',
      'forecast': 'Down',
      'actual': 'Down',
      'result': 'Hit',
      'forecastColor': AppColors.kred,
      'actualColor': AppColors.kred,
      'resultColor': AppColors.kgreen,
    },
    {
      'date': 'Aug 1 2025',
      'forecast': 'Down',
      'actual': 'Up',
      'result': 'Miss',
      'forecastColor': AppColors.kred,
      'actualColor': AppColors.kgreen,
      'resultColor': AppColors.kred,
    },
  ];

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome!', style: AppTextStyles.kswhite12500),
                      Text(
                        'Historical Trends',
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

              // Dropdown for Coins
              GestureDetector(
                onTap: () {
                  setState(() {
                    showDropdown = !showDropdown;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ksecondary,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.kwhite.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildCoinIcon(selectedCoinSymbol),
                      12.horizontalSpace,
                      Text(
                        selectedCoinSymbol,
                        style: AppTextStyles.ktwhite14500,
                      ),
                      const Spacer(),
                      Icon(
                        showDropdown
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.kwhite,
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              ),
              if (showDropdown)
                Container(
                  margin: EdgeInsets.only(top: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.ktertiary,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.kwhite.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: availableCoins.map((coin) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCoinSymbol = coin['symbol'];
                            showDropdown = false;
                          });
                          _loadTrendData();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.kwhite.withValues(alpha: 0.1),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildCoinIcon(coin['symbol']),
                              12.horizontalSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      coin['symbol'],
                                      style: AppTextStyles.ktwhite16600
                                          .copyWith(
                                            color: AppColors.kwhite,
                                            fontSize: 14.sp,
                                          ),
                                    ),
                                    Text(
                                      coin['name'],
                                      style: AppTextStyles.ktwhite14500
                                          .copyWith(
                                            color: AppColors.kwhite2,
                                            fontSize: 12.sp,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _getRealTimeAccuracy(coin['symbol']),
                                style: AppTextStyles.ktwhite14500.copyWith(
                                  color: AppColors.kgreen,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              16.verticalSpace,

              // Accuracy Card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.trendbg),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    _buildAccuracyCoinIcon(selectedCoinSymbol),
                    16.horizontalSpace,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCoinSymbol,
                          style: AppTextStyles.ktwhite16600.copyWith(
                            color: AppColors.kwhite,
                          ),
                        ),
                        Text(
                          _getSelectedCoinName(),
                          style: AppTextStyles.ktwhite14500.copyWith(
                            color: AppColors.kwhite,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Accuracy', style: AppTextStyles.ktwhite16600),
                        Text(
                          _getSelectedCoinAccuracy(),
                          style: AppTextStyles.kwhite32700,
                        ),
                      ],
                    ),
                    10.horizontalSpace,
                  ],
                ),
              ),
              12.verticalSpace,

              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.ksecondary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Time Filter',
                      style: AppTextStyles.kblack18500.copyWith(
                        color: AppColors.kwhite,
                      ),
                    ),
                    12.verticalSpace,
                    Text(
                      'Duration',
                      style: AppTextStyles.ktwhite14500.copyWith(
                        color: AppColors.kwhite2,
                      ),
                    ),
                    6.verticalSpace,
                    Row(
                      children: timeFilters.map((filter) {
                        bool isSelected = selectedTimeFilter == filter;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTimeFilter = filter;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 13.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.kprimary
                                  : AppColors.ksecondary,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              filter,
                              style: AppTextStyles.ktwhite14500.copyWith(
                                color: isSelected
                                    ? AppColors.kwhite
                                    : AppColors.kgrey11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              12.verticalSpace,

              // Forecast vs Actual Toggle
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.ksecondary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Forecast vs Actual / Accuracy',
                      style: AppTextStyles.kblack18500.copyWith(
                        color: AppColors.kwhite,
                      ),
                    ),
                    12.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Forecast vs Actual',
                          style: AppTextStyles.kblack14500.copyWith(
                            color: AppColors.kwhite,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              forecastVsActual = !forecastVsActual;
                              showTrendHistory = forecastVsActual;
                            });
                          },
                          child: Container(
                            width: 50.w,
                            height: 28.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.r),
                              color: forecastVsActual
                                  ? AppColors.kgreen
                                  : AppColors.kscoffald,
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              alignment: forecastVsActual
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 24.w,
                                height: 24.h,
                                margin: EdgeInsets.all(2.w),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              12.verticalSpace,

              // Chart or Trend History
              showTrendHistory ? _buildTrendHistory() : _buildChart(),

              12.verticalSpace,

              // Export CSV Button
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 16.w,
                  ),
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
                        AppImages.export,
                        width: 24.w,
                        height: 24.h,
                      ),
                      SizedBox(width: 8.w),
                      Text('Export CSV', style: AppTextStyles.ktwhite14500),
                    ],
                  ),
                ),
              ),
              100.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinIcon(String symbol) {
    final coin = availableCoins.firstWhere((c) => c['symbol'] == symbol);
    return Container(
      width: 28.w,
      height: 28.h,
      decoration: BoxDecoration(
        color: coin['image'] != null ? Colors.transparent : AppColors.kprimary,
        shape: BoxShape.circle,
      ),
      child: coin['image'] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                coin['image'],
                width: 28.w,
                height: 28.h,
                fit: BoxFit.cover,
              ),
            )
          : Center(
              child: Text(
                symbol.substring(0, 1),
                style: AppTextStyles.ktwhite14500.copyWith(
                  color: AppColors.kwhite,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Widget _buildAccuracyCoinIcon(String symbol) {
    final coin = availableCoins.firstWhere((c) => c['symbol'] == symbol);
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: coin['image'] != null ? Colors.transparent : AppColors.kprimary,
        shape: BoxShape.circle,
      ),
      child: coin['image'] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Image.asset(
                coin['image'],
                width: 40.w,
                height: 40.h,
                fit: BoxFit.cover,
              ),
            )
          : Center(
              child: Text(
                symbol.substring(0, 1),
                style: AppTextStyles.ktwhite16600.copyWith(
                  color: AppColors.kwhite,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  String _getSelectedCoinName() {
    final coin = availableCoins.firstWhere(
      (c) => c['symbol'] == selectedCoinSymbol,
    );
    return coin['name'];
  }

  String _getSelectedCoinAccuracy() {
    if (_realTimeAccuracy.containsKey(selectedCoinSymbol)) {
      return '${_realTimeAccuracy[selectedCoinSymbol]!.toStringAsFixed(1)}%';
    }
    if (_currentTrends != null) {
      // API already returns accuracy as percentage (e.g., 0.86 = 86%)
      return '${(_currentTrends!.accuracy * 100).toStringAsFixed(0)}%';
    }
    return '86%'; // Default fallback
  }

  String _getRealTimeAccuracy(String symbol) {
    if (_realTimeAccuracy.containsKey(symbol)) {
      return '${_realTimeAccuracy[symbol]!.toStringAsFixed(1)}%';
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

  Widget _buildChart() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.ksecondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Chart',
                style: AppTextStyles.kblack18500.copyWith(
                  color: AppColors.kwhite,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: const BoxDecoration(
                      color: AppColors.kgreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  8.horizontalSpace,
                  Text(
                    'Forecast',
                    style: AppTextStyles.kblack14700.copyWith(
                      color: AppColors.kwhite,
                    ),
                  ),
                  12.horizontalSpace,
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: AppColors.kwhite,
                      shape: BoxShape.circle,
                    ),
                  ),
                  8.horizontalSpace,
                  Text(
                    'Active',
                    style: AppTextStyles.kblack14700.copyWith(
                      color: AppColors.kwhite,
                    ),
                  ),
                ],
              ),
            ],
          ),
          24.verticalSpace,
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.ktertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Stack(
              children: [
                CustomPaint(painter: ChartPainter(), size: Size.infinite),
                Positioned(
                  bottom: 10.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                        [
                              '00:00',
                              '04:00',
                              '08:00',
                              '12:00',
                              '16:00',
                              '20:00',
                              '23:59',
                            ]
                            .map(
                              (time) => Text(
                                time,
                                style: AppTextStyles.kblack12400.copyWith(
                                  color: AppColors.kwhite,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendHistory() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.ksecondary, // Dark background matching the image
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend History',
            style: AppTextStyles.kmwhite16600, // Matching the bold white title
          ),
          16.verticalSpace,
          Column(
            children: [
              // Table Header
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Date',
                      style: AppTextStyles.kmwhite12700, // Light gray header text
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Forecast',
                      style: AppTextStyles.kmwhite12700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Actual',
                      style: AppTextStyles.kmwhite12700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Result',
                      style: AppTextStyles.kmwhite12700,
                    ),
                  ),
                ],
              ),
              12.verticalSpace,
              Divider(
                color: AppColors.kwhite3, // Light divider line
                height: 1.h,
              ),
              12.verticalSpace,
              // Table Rows - Use real-time data when available, fallback to static data
              ...(_realTimeTrendHistory.isNotEmpty ? _realTimeTrendHistory : trendHistoryData).map(
                    (data) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h), // Spacing between rows
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Date column - Fixed width
                      Expanded(
                        flex: 2,
                        child: Text(
                          data['date'],
                          style: AppTextStyles.kmwhite10600, // Smaller date text
                        ),
                      ),
                      // Forecast column - Dynamic container size
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: data['forecastColor'].withValues(
                                alpha: 0.16, // Light background for forecast
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: IntrinsicWidth(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    data['forecast'] == 'Up' ? AppImages.up : AppImages.down,
                                    width: 12.w,
                                    height: 12.h,
                                  ),
                                  Text(
                                    data['forecast'],
                                    style: AppTextStyles.ktblack8700.copyWith(
                                      color: data['forecastColor'],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Actual column - Dynamic container size
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: data['actualColor'].withValues(
                                alpha: 0.16, // Light background for actual
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: IntrinsicWidth(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    data['actual'] == 'Up' ? AppImages.up : AppImages.down,
                                    width: 12.w,
                                    height: 12.h,
                                  ),
                                  Text(
                                    data['actual'],
                                    style: AppTextStyles.ktblack8700.copyWith(
                                      color: data['actualColor'],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Result column - Dynamic container size
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: IntrinsicWidth(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  data['result'] == 'Hit'
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: data['resultColor'],
                                  size: 16.r,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  data['result'],
                                  style: AppTextStyles.kmwhite12700.copyWith(
                                    color: data['resultColor'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines
    _drawGridLines(canvas, size);

    // Draw the lines
    _drawForecastLine(canvas, size);
    _drawActiveLine(canvas, size);

    // Draw data points and price tooltip
    _drawDataPoints(canvas, size);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines
    for (int i = 0; i <= 6; i++) {
      final y = (size.height / 6) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw vertical grid lines
    for (int i = 0; i <= 6; i++) {
      final x = (size.width / 6) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height * 0.85), // Don't draw over time labels
        gridPaint,
      );
    }
  }

  void _drawForecastLine(Canvas canvas, Size size) {
    final forecastPaint = Paint()
      ..color = AppColors.kgreen
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create smooth forecast line with circular curves
    final forecastPath = Path();

    // Define data points for forecast line with circular movement
    final forecastPoints = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.14, size.height * 0.6),
      Offset(size.width * 0.28, size.height * 0.75),
      Offset(size.width * 0.42, size.height * 0.65),
      Offset(size.width * 0.56, size.height * 0.8),
      Offset(size.width * 0.7, size.height * 0.45),
      Offset(size.width * 0.84, size.height * 0.65),
      Offset(size.width, size.height * 0.55),
    ];

    forecastPath.moveTo(forecastPoints[0].dx, forecastPoints[0].dy);

    // Create smooth circular curves between points using cubic bezier
    for (int i = 0; i < forecastPoints.length - 1; i++) {
      final current = forecastPoints[i];
      final next = forecastPoints[i + 1];

      // Calculate control points for circular curves
      final distance = (next.dx - current.dx);
      final midX = current.dx + distance * 0.5;

      // Create circular arc effect with control points
      final controlPoint1 = Offset(
        current.dx + distance * 0.25,
        current.dy + (next.dy - current.dy) * 0.1,
      );

      final controlPoint2 = Offset(
        current.dx + distance * 0.75,
        next.dy + (current.dy - next.dy) * 0.1,
      );

      forecastPath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        next.dx, next.dy,
      );
    }

    // Draw dashed line effect
    _drawDashedPath(canvas, forecastPath, forecastPaint, dashWidth: 8, gapWidth: 4);
  }

  void _drawActiveLine(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create smooth active line with circular curves
    final activePath = Path();

    // Define data points for active line with circular movement
    final activePoints = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.12, size.height * 0.5),
      Offset(size.width * 0.24, size.height * 0.6),
      Offset(size.width * 0.36, size.height * 0.4),
      Offset(size.width * 0.48, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.72, size.height * 0.2),
      Offset(size.width * 0.84, size.height * 0.45),
      Offset(size.width, size.height * 0.35),
    ];

    activePath.moveTo(activePoints[0].dx, activePoints[0].dy);

    // Create smooth circular curves between points using cubic bezier
    for (int i = 0; i < activePoints.length - 1; i++) {
      final current = activePoints[i];
      final next = activePoints[i + 1];

      // Calculate control points for circular curves
      final distance = (next.dx - current.dx);

      // Create more circular arc effect with better control points
      final controlPoint1 = Offset(
        current.dx + distance * 0.3,
        current.dy + (next.dy - current.dy) * 0.1,
      );

      final controlPoint2 = Offset(
        current.dx + distance * 0.7,
        next.dy + (current.dy - next.dy) * 0.1,
      );

      activePath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        next.dx, next.dy,
      );
    }

    canvas.drawPath(activePath, activePaint);
  }

  void _drawDataPoints(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true; // Ensures smooth edges for circular points

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true; // Smooth outline

    // Draw shadow for forecast points
    final shadowPaint = Paint()
      ..color = AppColors.kgreen.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0); // Shadow effect

    // Draw forecast line points (green)
    pointPaint.color = AppColors.kgreen;
    outlinePaint.color = AppColors.kgreen.withOpacity(0.8);
    final forecastHighPoint = Offset(size.width * 0.7, size.height * 0.45);

    // Draw shadow
    canvas.drawCircle(forecastHighPoint, 6, shadowPaint); // Larger shadow radius
    // Draw filled circle
    canvas.drawCircle(forecastHighPoint, 5, pointPaint); // Increased radius
    // Draw outline
    canvas.drawCircle(forecastHighPoint, 5, outlinePaint);

    // Draw shadow for active points
    shadowPaint.color = Colors.white.withOpacity(0.3);
    pointPaint.color = Colors.white;
    outlinePaint.color = Colors.white.withOpacity(0.8);
    final activeHighPoint = Offset(size.width * 0.72, size.height * 0.2);

    // Draw shadow
    canvas.drawCircle(activeHighPoint, 6, shadowPaint); // Larger shadow radius
    // Draw filled circle
    canvas.drawCircle(activeHighPoint, 5, pointPaint); // Increased radius
    // Draw outline
    canvas.drawCircle(activeHighPoint, 5, outlinePaint);
  }

  void _drawPriceTooltip(Canvas canvas, Size size) {
    final tooltipPoint = Offset(size.width * 0.72, size.height * 0.2);

    // Draw tooltip background
    final tooltipPaint = Paint()
      ..color = AppColors.kgreen
      ..style = PaintingStyle.fill;

    final tooltipRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(tooltipPoint.dx, tooltipPoint.dy - 30),
        width: 90,
        height: 25,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(tooltipRect, tooltipPaint);

    // Draw tooltip text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\$54,382.64',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        tooltipPoint.dx - textPainter.width / 2,
        tooltipPoint.dy - 42,
      ),
    );
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, {required double dashWidth, required double gapWidth}) {
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final segment = pathMetric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(segment, paint);
        distance += dashWidth + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
