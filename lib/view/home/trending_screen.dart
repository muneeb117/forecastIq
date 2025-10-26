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

class TrendingScreen extends GetView<ForecastController> {
  const TrendingScreen({super.key});

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
                  Text('Trending', style: AppTextStyles.ktwhite16500),
                  SizedBox(width: 24.w),
                ],
              ),
            ),
            22.verticalSpace,

            // Content - All trending assets sorted by confidence
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return ListViewSkeleton(
                    itemCount: 6,
                    skeleton: const AssetListItemSkeleton(),
                  );
                }

                if (controller.allAssets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 64.r,
                          color: AppColors.kwhite2,
                        ),
                        16.verticalSpace,
                        Text(
                          'No Trending Assets',
                          style: AppTextStyles.kblack18500.copyWith(
                            color: AppColors.kwhite,
                          ),
                        ),
                        8.verticalSpace,
                        Text(
                          'Check back later for trending market data',
                          style: AppTextStyles.ktwhite14500.copyWith(
                            color: AppColors.kwhite2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Show all assets sorted by confidence (trending)
                final trendingAssets = _getTrendingAssets(controller.allAssets);

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: trendingAssets.length,
                  itemBuilder: (context, index) {
                    final asset = trendingAssets[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildAssetItem(asset),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<MarketSummary> _getTrendingAssets(List<MarketSummary> assets) {
    // Sort by confidence (highest first) - trending means high confidence
    final sortedAssets = List<MarketSummary>.from(assets);
    sortedAssets.sort((a, b) {
      // Sort by confidence first
      final confidenceCompare = b.confidence.compareTo(a.confidence);
      if (confidenceCompare != 0) return confidenceCompare;

      // If confidence is same, sort by 24h change (highest first)
      return b.change24h.abs().compareTo(a.change24h.abs());
    });
    return sortedAssets;
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