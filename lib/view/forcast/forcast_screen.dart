import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/images.dart';
import '../../models/models.dart';
import '../../widgets/item_widget.dart';
import '../../controllers/forecast_controller.dart';
import '../notifications/notifications_list_screen.dart';

class ForcastScreen extends GetView<ForecastController> {
  const ForcastScreen({super.key});

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
                        onChanged: (value) => controller.updateSearchQuery(value),
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
                  itemCount: controller.tabs.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      bool isSelected = controller.selectedTabIndex.value == index;
                      return GestureDetector(
                        onTap: () => controller.changeTab(index),
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
                              controller.tabs[index],
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
                    });
                  },
                ),
              ),

              23.verticalSpace,
              Obx(() => _buildTabContent()),
              100.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (controller.selectedTabIndex.value) {
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
    return _buildForecastContent(controller.getFilteredForecasts(controller.allAssets));
  }

  Widget _buildStocksContent() {
    return _buildForecastContent(controller.getFilteredForecasts(controller.stockAssets));
  }

  Widget _buildCryptoContent() {
    return _buildForecastContent(controller.getFilteredForecasts(controller.cryptoAssets));
  }

  Widget _buildMacroContent() {
    return _buildForecastContent(controller.getFilteredForecasts(controller.macroAssets));
  }

  Widget _buildFavoritesContent() {
    if (controller.isLoading.value) {
      return Center(child: CircularProgressIndicator(color: AppColors.kprimary));
    }

    if (controller.favoriteAssets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppImages.heart,
              width: 64.w,
              height: 64.h,
              colorFilter: ColorFilter.mode(AppColors.kwhite2, BlendMode.srcIn),
            ),
            16.verticalSpace,
            Text(
              'No Favorites Yet',
              style: AppTextStyles.kblack18500.copyWith(
                color: AppColors.kwhite,
              ),
            ),
            8.verticalSpace,
            Text(
              'Tap the heart icon in any asset detail screen to add it to your favorites',
              style: AppTextStyles.ktwhite14500.copyWith(
                color: AppColors.kwhite2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _buildForecastContent(controller.getFilteredForecasts(controller.favoriteAssets));
  }

  Widget _buildForecastContent(List<MarketSummary> forecasts) {
    if (controller.isLoading.value) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.kprimary),
      );
    }

    if (forecasts.isEmpty) {
      return Center(
        child: Text(
          controller.searchQuery.value.isNotEmpty
              ? 'No results found for "${controller.searchQuery.value}"'
              : 'No data available',
          style: AppTextStyles.kblack16500.copyWith(color: AppColors.kwhite2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...forecasts.map((forecast) => Column(
          children: [
            buildTrendingItem(
              controller.getAssetIcon(forecast.symbol),
              forecast.symbol,
              forecast.name,
              '${forecast.confidence.toString()}%',
              forecast.forecastDirection.toLowerCase() == 'up',
              controller.formatPredictedRange(forecast.predictedRange),
              isUpdating: controller.isUpdating[forecast.symbol] ?? false,
            ),
            SizedBox(height: 12.h),
          ],
        )).toList(),
      ],
    );
  }
}