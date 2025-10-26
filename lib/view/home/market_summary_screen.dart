import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:get/get.dart';
import '../../controllers/forecast_controller.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../models/models.dart';
import '../../widgets/item_widget.dart';
import '../../widgets/skeleton_widgets.dart';

class MarketSummaryScreen extends GetView<ForecastController> {
  const MarketSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      AppImages.left,
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                  Text('Market Summary', style: AppTextStyles.ktwhite16500),
                  SizedBox(width: 24.w),
                ],
              ),
            ),
            22.verticalSpace,

            // Tabs (without Favorites) - Fixed height
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              height: 31.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4, // All, Stocks, Crypto, Macro
                itemBuilder: (context, index) {
                  final marketTabs = ['All', 'Stocks', 'Crypto', 'Macro'];
                  final tabName = marketTabs[index];
                  final originalIndex = controller.tabs.indexOf(tabName);

                  return Obx(() {
                    bool isSelected = controller.selectedTabIndex.value == originalIndex;

                    return GestureDetector(
                      onTap: () => controller.changeTab(originalIndex),
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
                            tabName,
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

            16.verticalSpace,

            // Content
            Expanded(
              child: Obx(() => _buildTabContent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (controller.selectedTabIndex.value) {
      case 0: // All
        return _buildAssetList(controller.allAssets);
      case 1: // Stocks
        return _buildAssetList(controller.stockAssets);
      case 2: // Crypto
        return _buildAssetList(controller.cryptoAssets);
      case 3: // Macro
        return _buildAssetList(controller.macroAssets);
      case 4: // Favorites
        return _buildFavoritesList();
      default:
        return _buildAssetList(controller.allAssets);
    }
  }

  Widget _buildAssetList(List<MarketSummary> assets) {
    if (controller.isLoading.value) {
      return ListViewSkeleton(
        itemCount: 6,
        skeleton: const AssetListItemSkeleton(),
      );
    }

    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64.r,
              color: AppColors.kwhite2,
            ),
            16.verticalSpace,
            Text(
              'No Assets Available',
              style: AppTextStyles.kblack18500.copyWith(
                color: AppColors.kwhite,
              ),
            ),
            8.verticalSpace,
            Text(
              'Market data will appear here',
              style: AppTextStyles.ktwhite14500.copyWith(
                color: AppColors.kwhite2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildAssetItem(asset),
        );
      },
    );
  }

  Widget _buildFavoritesList() {
    if (controller.isLoading.value) {
      return ListViewSkeleton(
        itemCount: 6,
        skeleton: const AssetListItemSkeleton(),
      );
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
              'Tap the heart icon on any asset to add it to your favorites',
              style: AppTextStyles.ktwhite14500.copyWith(
                color: AppColors.kwhite2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: controller.favoriteAssets.length,
      itemBuilder: (context, index) {
        final asset = controller.favoriteAssets[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildAssetItem(asset),
        );
      },
    );
  }

  Widget _buildAssetItem(MarketSummary asset) {
    // Get asset icon based on symbol
    String? iconPath = controller.getAssetIcon(asset.symbol);

    // Check if this asset is currently being updated
    bool isUpdating = controller.isUpdating[asset.symbol] ?? false;

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
}