import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import '../../models/asset_forecast.dart';
import '../../models/asset_trends.dart';
import '../../models/market_summary.dart';
import '../../services/trading_ai_service.dart';
import '../../services/websocket_service.dart';


class PredictionDashboard extends StatefulWidget {
  const PredictionDashboard({super.key});

  @override
  State<PredictionDashboard> createState() => _PredictionDashboardState();
}

class _PredictionDashboardState extends State<PredictionDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  final TradingAIService _tradingService = TradingAIService();
  final WebSocketManager _wsManager = WebSocketManager();

  List<MarketSummary> cryptoSummary = [];
  List<MarketSummary> stockSummary = [];
  List<MarketSummary> macroSummary = [];

  bool isLoading = true;
  String selectedTimeframe = '1D';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMarketData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _wsManager.disposeAll();
    super.dispose();
  }

  Future<void> _loadMarketData() async {
    setState(() => isLoading = true);

    try {
      final results = await Future.wait([
        _tradingService.getMarketSummary(assetClass: 'crypto', limit: 10),
        _tradingService.getMarketSummary(assetClass: 'stocks', limit: 10),
        _tradingService.getMarketSummary(assetClass: 'macro', limit: 5),
      ]);

      setState(() {
        cryptoSummary = results[0] as List<MarketSummary>;
        stockSummary = results[1] as List<MarketSummary>;
        macroSummary = results[2] as List<MarketSummary>;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading market data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      appBar: AppBar(
        backgroundColor: AppColors.kscoffald,
        title: Text(
          'AI Predictions',
          style: TextStyle(
            color: AppColors.kwhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.kwhite, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.kprimary, size: 24.sp),
            onPressed: _loadMarketData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.kprimary,
          labelColor: AppColors.kprimary,
          unselectedLabelColor: AppColors.kgrey2,
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Crypto'),
            Tab(text: 'Stocks'),
            Tab(text: 'Macro'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.kprimary),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAssetList(cryptoSummary, 'crypto'),
                _buildAssetList(stockSummary, 'stocks'),
                _buildAssetList(macroSummary, 'macro'),
              ],
            ),
    );
  }

  Widget _buildAssetList(List<MarketSummary> assets, String assetType) {
    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 64.sp,
              color: AppColors.kgrey2,
            ),
            SizedBox(height: 16.h),
            Text(
              'No data available',
              style: TextStyle(
                color: AppColors.kgrey2,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMarketData,
      color: AppColors.kprimary,
      backgroundColor: AppColors.ksecondary,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          return _buildAssetCard(asset);
        },
      ),
    );
  }

  Widget _buildAssetCard(MarketSummary asset) {
    final isPositive = asset.changePercentage24h >= 0;
    final changeColor = isPositive ? AppColors.kgreen : AppColors.kred;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.ksecondary,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.ktertiary, width: 1),
      ),
      child: InkWell(
        onTap: () => _navigateToAssetDetail(asset),
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.kprimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    _getAssetIcon(asset.assetClass),
                    color: AppColors.kprimary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.symbol,
                        style: TextStyle(
                          color: AppColors.kwhite,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (asset.name.isNotEmpty)
                        Text(
                          asset.name,
                          style: TextStyle(
                            color: AppColors.kgrey2,
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${asset.currentPrice.toStringAsFixed(asset.currentPrice < 1 ? 4 : 2)}',
                      style: TextStyle(
                        color: AppColors.kwhite,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: changeColor,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${isPositive ? '+' : ''}${asset.changePercentage24h.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: changeColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.ktertiary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: AppColors.kprimary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Tap for AI Prediction',
                    style: TextStyle(
                      color: AppColors.kprimary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.kprimary,
                    size: 12.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAssetIcon(String assetClass) {
    switch (assetClass.toLowerCase()) {
      case 'crypto':
        return Icons.currency_bitcoin;
      case 'stocks':
        return Icons.trending_up;
      case 'macro':
        return Icons.public;
      default:
        return Icons.show_chart;
    }
  }

  void _navigateToAssetDetail(MarketSummary asset) {
    Get.to(() => AssetDetailScreen(asset: asset));
  }
}

class AssetDetailScreen extends StatefulWidget {
  final MarketSummary asset;

  const AssetDetailScreen({super.key, required this.asset});

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  final TradingAIService _tradingService = TradingAIService();
  final WebSocketService _wsService = WebSocketService();

  AssetForecast? forecast;
  AssetTrends? trends;
  bool isLoadingForecast = true;
  bool isLoadingTrends = true;
  String selectedTimeframe = '1D';

  @override
  void initState() {
    super.initState();
    _loadAssetData();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }

  Future<void> _loadAssetData() async {
    setState(() {
      isLoadingForecast = true;
      isLoadingTrends = true;
    });

    try {
      final results = await Future.wait([
        _tradingService.getAssetForecast(widget.asset.symbol, timeframe: selectedTimeframe),
        _tradingService.getAssetTrends(widget.asset.symbol),
      ]);

      setState(() {
        forecast = results[0] as AssetForecast?;
        trends = results[1] as AssetTrends?;
        isLoadingForecast = false;
        isLoadingTrends = false;
      });
    } catch (e) {
      setState(() {
        isLoadingForecast = false;
        isLoadingTrends = false;
      });
    }
  }

  void _connectWebSocket() {
    _wsService.connectToAssetForecast(widget.asset.symbol);
    _wsService.stream?.listen((data) {
      if (mounted) {
        try {
          final newForecast = AssetForecast.fromJson(data);
          setState(() {
            forecast = newForecast;
          });
        } catch (e) {
          //print('Error parsing real-time forecast: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      appBar: AppBar(
        backgroundColor: AppColors.kscoffald,
        title: Text(
          widget.asset.symbol,
          style: TextStyle(
            color: AppColors.kwhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.kwhite, size: 20.sp),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceCard(),
            SizedBox(height: 16.h),
            _buildTimeframeSelector(),
            SizedBox(height: 16.h),
            _buildForecastCard(),
            SizedBox(height: 16.h),
            _buildTrendsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    final isPositive = widget.asset.changePercentage24h >= 0;
    final changeColor = isPositive ? AppColors.kgreen : AppColors.kred;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.ksecondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.ktertiary, width: 1),
      ),
      child: Column(
        children: [
          Text(
            '\$${widget.asset.currentPrice.toStringAsFixed(widget.asset.currentPrice < 1 ? 4 : 2)}',
            style: TextStyle(
              color: AppColors.kwhite,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: changeColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '${isPositive ? '+' : ''}${widget.asset.changePercentage24h.toStringAsFixed(2)}% (24h)',
                style: TextStyle(
                  color: changeColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    const timeframes = ['1H', '4H', '1D', '1W', '1M'];

    return Container(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: timeframes.length,
        itemBuilder: (context, index) {
          final timeframe = timeframes[index];
          final isSelected = timeframe == selectedTimeframe;

          return GestureDetector(
            onTap: () {
              setState(() => selectedTimeframe = timeframe);
              _loadAssetData();
            },
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.kprimary : AppColors.ksecondary,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? AppColors.kprimary : AppColors.ktertiary,
                  width: 1,
                ),
              ),
              child: Text(
                timeframe,
                style: TextStyle(
                  color: isSelected ? AppColors.kwhite : AppColors.kgrey2,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForecastCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.ksecondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.ktertiary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: AppColors.kprimary,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'AI Prediction',
                style: TextStyle(
                  color: AppColors.kwhite,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (isLoadingForecast)
            const Center(
              child: CircularProgressIndicator(color: AppColors.kprimary),
            )
          else if (forecast != null)
            _buildForecastContent()
          else
            _buildErrorMessage('Unable to load forecast data'),
        ],
      ),
    );
  }

  Widget _buildForecastContent() {
    if (forecast == null) return const SizedBox();

    final isPositive = forecast!.change24h >= 0;
    final changeColor = isPositive ? AppColors.kgreen : AppColors.kred;

    return Column(
      children: [
        // Forecast Direction
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _getDirectionColor(forecast!.forecastDirection).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getDirectionIcon(forecast!.forecastDirection),
                color: _getDirectionColor(forecast!.forecastDirection),
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                forecast!.forecastDirection,
                style: TextStyle(
                  color: _getDirectionColor(forecast!.forecastDirection),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Predicted Range',
                  style: TextStyle(
                    color: AppColors.kgrey2,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  forecast!.predictedRange.isNotEmpty ? forecast!.predictedRange : 'N/A',
                  style: TextStyle(
                    color: AppColors.kwhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Volume',
                  style: TextStyle(
                    color: AppColors.kgrey2,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  _formatVolume(forecast!.volume),
                  style: TextStyle(
                    color: AppColors.kwhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Chart section with real data
        if (forecast!.chart != null) _buildRealChart(),

        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.ktertiary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified,
                color: AppColors.kprimary,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Confidence: ${forecast!.confidence}%',
                style: TextStyle(
                  color: AppColors.kwhite,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRealChart() {
    if (forecast?.chart == null) return SizedBox();

    final chartData = forecast!.chart!;
    final pastPrices = chartData['past'] as List? ?? [];
    final futurePrices = chartData['future'] as List? ?? [];
    final timestamps = chartData['timestamps'] as List? ?? [];

    return Container(
      height: 200.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.ktertiary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Chart',
            style: TextStyle(
              color: AppColors.kwhite,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: Row(
              children: [
                // Past data
                if (pastPrices.isNotEmpty)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Current',
                          style: TextStyle(
                            color: AppColors.kgrey2,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          '\$${pastPrices.last.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.kwhite,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Arrow
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.kprimary,
                  size: 24.sp,
                ),
                // Future data
                if (futurePrices.isNotEmpty)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Predicted',
                          style: TextStyle(
                            color: AppColors.kgrey2,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          '\$${futurePrices.first.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.kprimary,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (timestamps.isNotEmpty)
            Text(
              'Last updated: ${timestamps.last}',
              style: TextStyle(
                color: AppColors.kgrey2,
                fontSize: 10.sp,
              ),
            ),
        ],
      ),
    );
  }

  Color _getDirectionColor(String direction) {
    switch (direction.toUpperCase()) {
      case 'BUY':
      case 'UP':
        return AppColors.kgreen;
      case 'SELL':
      case 'DOWN':
        return AppColors.kred;
      case 'HOLD':
      default:
        return AppColors.kprimary;
    }
  }

  IconData _getDirectionIcon(String direction) {
    switch (direction.toUpperCase()) {
      case 'BUY':
      case 'UP':
        return Icons.trending_up;
      case 'SELL':
      case 'DOWN':
        return Icons.trending_down;
      case 'HOLD':
      default:
        return Icons.trending_flat;
    }
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  Widget _buildTrendsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.ksecondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.ktertiary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.kprimary,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Prediction Accuracy',
                style: TextStyle(
                  color: AppColors.kwhite,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (isLoadingTrends)
            const Center(
              child: CircularProgressIndicator(color: AppColors.kprimary),
            )
          else if (trends != null)
            _buildTrendsContent()
          else
            _buildErrorMessage('Unable to load trends data'),
        ],
      ),
    );
  }

  Widget _buildTrendsContent() {
    if (trends == null) return const SizedBox();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Accuracy',
                  style: TextStyle(
                    color: AppColors.kgrey2,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  '${(trends!.accuracy * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: AppColors.kprimary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Predictions',
                  style: TextStyle(
                    color: AppColors.kgrey2,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  '${trends!.correctPredictions}/${trends!.totalPredictions}',
                  style: TextStyle(
                    color: AppColors.kwhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.kred.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.kred,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.kred,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}