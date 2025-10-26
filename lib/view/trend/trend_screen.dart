import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:get/get.dart';
import '../../controllers/trend_controller.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../models/trend_data_model.dart' as trend_models;
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
                    onTap: () {
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
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Search bar
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.kwhite.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppColors.kwhite2,
                            size: 20.r,
                          ),
                          8.horizontalSpace,
                          Expanded(
                            child: TextField(
                              onChanged: (value) => controller.updateSearchQuery(value),
                              style: AppTextStyles.ktwhite14500.copyWith(
                                color: AppColors.kwhite,
                                fontSize: 14.sp,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search assets...',
                                hintStyle: AppTextStyles.ktwhite14500.copyWith(
                                  color: AppColors.kwhite2,
                                  fontSize: 14.sp,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Scrollable list
                    Obx(() {
                      final filteredCoins = controller.filteredCoins;
                      if (filteredCoins.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.h),
                          child: Text(
                            'No assets found',
                            style: AppTextStyles.ktwhite14500.copyWith(
                              color: AppColors.kwhite2,
                            ),
                          ),
                        );
                      }
                      return Container(
                        constraints: BoxConstraints(
                          maxHeight: 300.h, // Limit height for scrolling
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredCoins.length,
                          itemBuilder: (context, index) {
                            final coin = filteredCoins[index];
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
                          },
                        ),
                      );
                    }),
                  ],
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
                    // Hide timeframe filter for macro indicators
                    if (!controller.isMacroIndicator) ...[
                      6.verticalSpace,
                      Obx(() => Row(
                        children: controller.availableTimeFrames.asMap().entries.map((entry) {
                          int displayIndex = entry.key;
                          String filter = entry.value;
                          // Get the actual index in the full timeFrames list
                          int actualIndex = controller.timeFrames.indexOf(filter);
                          bool isSelected = controller.selectedTimeFrameIndex.value == actualIndex;
                          return GestureDetector(
                            onTap: () => controller.changeTimeFrame(actualIndex),
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
              Obx(() {
                if (controller.isLoading.value) {
                  return controller.showTrendHistory.value
                      ? _buildTrendHistoryShimmer()
                      : _buildChartShimmer();
                }
                return controller.showTrendHistory.value
                    ? _buildTrendHistory()
                    : _buildChart();
              }),

              12.verticalSpace,

              // Export CSV Button
              Center(
                child: GestureDetector(
                  onTap: () => controller.exportToCSV(),
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

  Widget _buildChartShimmer() {
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
              _buildShimmerPlaceholder(height: 20.h, width: 80.w),
              const Spacer(),
              _buildShimmerPlaceholder(height: 20.h, width: 120.w),
            ],
          ),
          24.verticalSpace,
          _buildShimmerPlaceholder(
            height: 200.h,
            width: double.infinity,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendHistoryShimmer() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.ksecondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerPlaceholder(height: 20.h, width: 150.w),
          16.verticalSpace,
          Row(
            children: [
              Expanded(flex: 2, child: _buildShimmerPlaceholder(height: 16.h, width: double.infinity)),
              SizedBox(width: 12.w),
              Expanded(child: _buildShimmerPlaceholder(height: 16.h, width: double.infinity)),
              SizedBox(width: 12.w),
              Expanded(child: _buildShimmerPlaceholder(height: 16.h, width: double.infinity)),
              SizedBox(width: 12.w),
              Expanded(child: _buildShimmerPlaceholder(height: 16.h, width: double.infinity)),
            ],
          ),
          12.verticalSpace,
          Divider(color: AppColors.kwhite3, height: 1.h),
          12.verticalSpace,
          ...List.generate(5, (index) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildShimmerPlaceholder(height: 16.h, width: double.infinity)),
                SizedBox(width: 12.w),
                Expanded(child: _buildShimmerPlaceholder(height: 16.h, width: double.infinity)),
                SizedBox(width: 12.w),
                Expanded(child: _buildShimmerPlaceholder(height: 16.h, width: double.infinity)),
                SizedBox(width: 12.w),
                Expanded(child: _buildShimmerPlaceholder(height: 16.h, width: double.infinity)),
              ],
            ),
          )),
        ],
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
            child: Obx(() => controller.hasData
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
    if (!controller.hasData || controller.trendData.value!.accuracyHistory.isEmpty) {
      return Center(
        child: Text(
          'No time data available',
          style: AppTextStyles.kblack12400.copyWith(
            color: AppColors.kwhite,
          ),
        ),
      );
    }

    final history = controller.trendData.value!.accuracyHistory;
    // Select up to 7 labels to avoid clutter, evenly spaced
    const maxLabels = 7;
    final step = (history.length / maxLabels).ceil();
    final labels = <String>[];

    for (int i = 0; i < history.length && labels.length < maxLabels; i += step) {
      labels.add(_formatDate(history[i].date));
    }

    // Ensure the last date is included if possible
    if (history.length > maxLabels && labels.length == maxLabels) {
      labels[maxLabels - 1] = _formatDate(history.last.date);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: labels
          .map(
            (label) => Text(
          label,
          style: AppTextStyles.kblack12400.copyWith(
            color: AppColors.kwhite,
            fontSize: 10.sp, // Adjust font size for readability
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
                      final predicted = historyItem.predicted;
                      final actual = historyItem.actual;

                      Map<String, dynamic> forecastTrend;
                      Map<String, dynamic> actualTrend;

                      if (isHit) {
                        if (predicted < actual) { // User rule 1: Hit, pred < act -> Up, Up
                          forecastTrend = {'text': 'Up', 'color': AppColors.kgreen, 'icon': AppImages.up};
                          actualTrend = {'text': 'Up', 'color': AppColors.kgreen, 'icon': AppImages.up};
                        } else { // User rule 2: Hit, pred >= act -> Down, Down
                          forecastTrend = {'text': 'Down', 'color': AppColors.kred, 'icon': AppImages.down};
                          actualTrend = {'text': 'Down', 'color': AppColors.kred, 'icon': AppImages.down};
                        }
                      } else { // Miss
                        if (predicted > actual) { // User rule 3: Miss, pred > act -> pred Up, act Down
                          forecastTrend = {'text': 'Up', 'color': AppColors.kgreen, 'icon': AppImages.up};
                          actualTrend = {'text': 'Down', 'color': AppColors.kred, 'icon': AppImages.down};
                        } else { // User rule 4: Miss, act >= pred -> pred Down, act Up
                          forecastTrend = {'text': 'Down', 'color': AppColors.kred, 'icon': AppImages.down};
                          actualTrend = {'text': 'Up', 'color': AppColors.kgreen, 'icon': AppImages.up};
                        }
                      }

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

class _Shimmer extends StatefulWidget {
  const _Shimmer({
    required this.child,
  });

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
              colors: const [
                Color(0xFF3A3A3A),
                Color(0xFF4A4A4A),
                Color(0xFF3A3A3A),
              ],
              stops: const [0.4, 0.5, 0.6],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

Widget _buildShimmerPlaceholder({
  required double height,
  required double width,
  BorderRadius? borderRadius,
}) {
  return _Shimmer(
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    ),
  );
}