import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:get/get.dart';
import '../../controllers/trend_controller.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../models/trend_data_model.dart' as trend_models;
import '../../controllers/trend_controller.dart';
import '../notifications/notifications_list_screen.dart';

class TrendScreen extends GetView<TrendController> {
  const TrendScreen({super.key});

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
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsListScreen(),
                        ),
                      );
                    },
                    child: Container(
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
                  ),
                ],
              ),
              23.verticalSpace,

              // Dropdown for Coins
              Obx(() => GestureDetector(
                onTap: () => controller.toggleDropdown(),
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
                      _buildCoinIcon(controller.selectedCoinSymbol.value),
                      12.horizontalSpace,
                      Text(
                        controller.selectedCoinSymbol.value,
                        style: AppTextStyles.ktwhite14500,
                      ),
                      const Spacer(),
                      Icon(
                        controller.showDropdown.value
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.kwhite,
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              )),

              Obx(() => controller.showDropdown.value
                  ? Container(
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
                        children: controller.availableCoins.map((coin) {
                          return GestureDetector(
                            onTap: () => controller.selectCoin(coin['symbol']),
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
                                          style: AppTextStyles.ktwhite16600.copyWith(
                                            color: AppColors.kwhite,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        Text(
                                          coin['name'],
                                          style: AppTextStyles.ktwhite14500.copyWith(
                                            color: AppColors.kwhite2,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    controller.getRealTimeAccuracy(coin['symbol']),
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
                    )
                  : SizedBox.shrink()),
              16.verticalSpace,

              // Accuracy Card
              Obx(() => Container(
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
                    _buildAccuracyCoinIcon(controller.selectedCoinSymbol.value),
                    16.horizontalSpace,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.selectedCoinSymbol.value,
                          style: AppTextStyles.ktwhite16600.copyWith(
                            color: AppColors.kwhite,
                          ),
                        ),
                        Text(
                          controller.getSelectedCoinName(),
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
                          controller.getSelectedCoinAccuracy(),
                          style: AppTextStyles.kwhite32700,
                        ),
                      ],
                    ),
                    10.horizontalSpace,
                  ],
                ),
              )),
              12.verticalSpace,

              // Time Filter
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
                    Obx(() => Row(
                      children: controller.timeFrames.asMap().entries.map((entry) {
                        int index = entry.key;
                        String filter = entry.value;
                        bool isSelected = controller.selectedTimeFrameIndex.value == index;
                        return GestureDetector(
                          onTap: () => controller.changeTimeFrame(index),
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
                    )),
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
                        Obx(() => GestureDetector(
                          onTap: () => controller.toggleForecastVsActual(),
                          child: Container(
                            width: 50.w,
                            height: 28.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.r),
                              color: controller.forecastVsActual.value
                                  ? AppColors.kgreen
                                  : AppColors.kscoffald,
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              alignment: controller.forecastVsActual.value
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
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              12.verticalSpace,

              // Chart or Trend History
              Obx(() => controller.showTrendHistory.value
                  ? _buildTrendHistory()
                  : _buildChart()),

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
    final coin = controller.availableCoins.firstWhere(
      (c) => c['symbol'] == symbol,
      orElse: () => {'symbol': symbol, 'name': symbol, 'image': null},
    );
    return Container(
      width: 28.w,
      height: 28.h,
      decoration: BoxDecoration(
        color: coin['image'] != null ? Colors.transparent : AppColors.kprimary,
        shape: BoxShape.circle,
      ),
      child: coin['image'] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Image.asset(
                coin['image'],
                width: 28.w,
                height: 28.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      symbol.substring(0, 1),
                      style: AppTextStyles.ktwhite14500.copyWith(
                        color: AppColors.kwhite,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
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
    final coin = controller.availableCoins.firstWhere(
      (c) => c['symbol'] == symbol,
      orElse: () => {'symbol': symbol, 'name': symbol, 'image': null},
    );
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
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      symbol.substring(0, 1),
                      style: AppTextStyles.ktwhite16600.copyWith(
                        color: AppColors.kwhite,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
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
                    'Actual',
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
            child: Obx(() => controller.isLoading.value
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.kprimary),
                  )
                : controller.hasData
                    ? Stack(
                        children: [
                          CustomPaint(
                            painter: ChartPainter(apiData: controller.trendData.value),
                            size: Size.infinite,
                          ),
                          Positioned(
                            bottom: 10.h,
                            left: 0,
                            right: 0,
                            child: _buildTimeLabels(),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          'No data available',
                          style: AppTextStyles.kblack14500.copyWith(
                            color: AppColors.kwhite2,
                          ),
                        ),
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLabels() {
    final timeframe = controller.currentTimeFrame;
    List<String> labels;

    switch (timeframe) {
      case '1H':
        labels = ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:59'];
        break;
      case '4H':
        labels = ['00:00', '06:00', '12:00', '18:00', '23:59'];
        break;
      case '1D':
        labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        break;
      case '7D':
        labels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        break;
      case '1M':
        labels = ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'];
        break;
      default:
        labels = ['Start', 'Mid', 'End'];
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: labels
          .map(
            (label) => Text(
              label,
              style: AppTextStyles.kblack12400.copyWith(
                color: AppColors.kwhite,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTrendHistory() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.ksecondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend History',
            style: AppTextStyles.kmwhite16600,
          ),
          16.verticalSpace,
          Obx(() => controller.hasData
              ? Column(
                  children: [
                    // Table Header
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Date',
                            style: AppTextStyles.kmwhite12700,
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
                      color: AppColors.kwhite3,
                      height: 1.h,
                    ),
                    12.verticalSpace,
                    // Real data rows from API
                    ...controller.trendData.value!.accuracyHistory.map((historyItem) {
                      final isHit = historyItem.isHit;
                      // Determine trend direction based on predicted vs actual values
                      final forecastTrend = _getTrendDirection(historyItem.predicted, historyItem.actual, true);
                      final actualTrend = _getTrendDirection(historyItem.actual, historyItem.predicted, false);

                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Date column
                            Expanded(
                              flex: 2,
                              child: Text(
                                _formatDate(historyItem.date),
                                style: AppTextStyles.kmwhite10600,
                              ),
                            ),
                            // Forecast column
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: forecastTrend['color'].withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        forecastTrend['icon'],
                                        width: 12.w,
                                        height: 12.h,
                                      ),
                                      Text(
                                        forecastTrend['text'],
                                        style: AppTextStyles.ktblack8700.copyWith(
                                          color: forecastTrend['color'],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Actual column
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: actualTrend['color'].withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        actualTrend['icon'],
                                        width: 12.w,
                                        height: 12.h,
                                      ),
                                      Text(
                                        actualTrend['text'],
                                        style: AppTextStyles.ktblack8700.copyWith(
                                          color: actualTrend['color'],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Result column
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isHit ? Icons.check_circle : Icons.cancel,
                                      color: isHit ? AppColors.kgreen : AppColors.kred,
                                      size: 16.r,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      historyItem.result,
                                      style: AppTextStyles.kmwhite12700.copyWith(
                                        color: isHit ? AppColors.kgreen : AppColors.kred,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                )
              : Center(
                  child: Text(
                    'No trend history available',
                    style: AppTextStyles.kblack14500.copyWith(
                      color: AppColors.kwhite2,
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    } catch (e) {
      return dateStr;
    }
  }

  Map<String, dynamic> _getTrendDirection(double value1, double value2, bool isPredicted) {
    // Simple trend logic - you can make this more sophisticated
    // For now, just compare if predicted is higher or lower than actual
    final isUp = value1 > value2;

    return {
      'text': isUp ? 'Up' : 'Down',
      'color': isUp ? AppColors.kgreen : AppColors.kred,
      'icon': isUp ? AppImages.up : AppImages.down,
    };
  }

}

class ChartPainter extends CustomPainter {
  final trend_models.TrendData? apiData;

  ChartPainter({this.apiData});

  @override
  void paint(Canvas canvas, Size size) {
    if (apiData == null || apiData!.chart.actual.isEmpty) {
      _drawEmptyState(canvas, size);
      return;
    }

    // Draw grid lines
    _drawGridLines(canvas, size);

    // Draw the lines using real API data
    _drawPredictedLine(canvas, size);
    _drawActualLine(canvas, size);
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Loading chart data...',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
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
        Offset(x, size.height * 0.85),
        gridPaint,
      );
    }
  }

  void _drawPredictedLine(Canvas canvas, Size size) {
    if (apiData!.chart.predicted.isEmpty) return;

    final predictedPaint = Paint()
      ..color = AppColors.kgreen
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final predictedPath = Path();
    final points = _getScaledPoints(apiData!.chart.predicted, size);

    if (points.isEmpty) return;

    predictedPath.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      predictedPath.lineTo(points[i].dx, points[i].dy);
    }

    // Draw as dashed line for predicted values
    _drawDashedPath(canvas, predictedPath, predictedPaint, dashWidth: 8, gapWidth: 4);
  }

  void _drawActualLine(Canvas canvas, Size size) {
    if (apiData!.chart.actual.isEmpty) return;

    final actualPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final actualPath = Path();
    final points = _getScaledPoints(apiData!.chart.actual, size);

    if (points.isEmpty) return;

    actualPath.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      actualPath.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(actualPath, actualPaint);
  }

  List<Offset> _getScaledPoints(List<double> values, Size size) {
    if (values.isEmpty) return [];

    final minPrice = apiData!.chart.minPrice;
    final maxPrice = apiData!.chart.maxPrice;
    final priceRange = maxPrice - minPrice;

    if (priceRange == 0) {
      // All values are the same, draw a horizontal line in the middle
      return values.asMap().entries.map((entry) {
        final x = (entry.key / (values.length - 1)) * size.width;
        return Offset(x, size.height * 0.5);
      }).toList();
    }

    return values.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;

      final x = (index / (values.length - 1)) * size.width;
      // Invert Y coordinate and add padding
      final normalizedY = (value - minPrice) / priceRange;
      final y = size.height * 0.85 - (normalizedY * size.height * 0.7); // Leave space for time labels

      return Offset(x, y);
    }).toList();
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
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is! ChartPainter) return true;
    return oldDelegate.apiData != apiData;
  }
}