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

import '../../services/auth_service.dart';
import '../notifications/notifications_list_screen.dart';
import 'trending_screen.dart';
import 'market_summary_screen.dart';

class HomeScreen extends GetView<ForecastController> {
   HomeScreen({super.key});

  final AuthService _authService = AuthService.instance;

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
                  Obx(() {
                    final profileImageUrl = _authService.userProfileImage;
                    final userName = _authService.userName ?? 'User';
                    final firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

                    return CircleAvatar(
                      radius: 24.r,
                      backgroundColor: AppColors.kprimary,
                      backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl == null || profileImageUrl.isEmpty
                          ? Text(
                              firstLetter,
                              style: AppTextStyles.ktwhite16600.copyWith(
                                color: AppColors.kwhite,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    );
                  }),
                  8.horizontalSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome!', style: AppTextStyles.kswhite12500),
                      Obx(() => Text(
                        'Hi ${_authService.userName ?? 'User'}!',
                        style: AppTextStyles.kblack18500.copyWith(
                          color: AppColors.kwhite,
                        ),
                      )),
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

              // Horizontal Tabs Section
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

              8.verticalSpace,

              // Content based on selected tab
              Obx(() => _buildTabContent(context)),
              100.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (controller.selectedTabIndex.value) {
      case 0: // All
        return _buildAllContent(context);
      case 1: // Stocks
        return _buildStocksContent();
      case 2: // Crypto
        return _buildCryptoContent();
      case 3: // Macro
        return _buildMacroContent();
      case 4: // Favorites
        return _buildFavoritesContent();
      default:
        return _buildAllContent(context);
    }
  }

  Widget _buildAllContent(BuildContext context) {
    if (controller.isLoading.value) {
      return Column(
        children: [
          const AssetListItemSkeleton(),
          12.verticalSpace,
          const AssetListItemSkeleton(),
          12.verticalSpace,
          const AssetListItemSkeleton(),
          12.verticalSpace,
          const AssetListItemSkeleton(),
        ],
      );
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrendingScreen(),
                  ),
                );
              },
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
        if (controller.allAssets.isNotEmpty)
          ...controller.allAssets.take(1).map((asset) => _buildAssetItem(asset)),

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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarketSummaryScreen(),
                  ),
                );
              },
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
        if (controller.allAssets.isNotEmpty)
          ...controller.allAssets.map((asset) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildAssetItem(asset),
          )),
      ],
    );
  }

  Widget _buildStocksContent() {
    if (controller.isLoading.value) {
      return Column(
        children: [
          const AssetListItemSkeleton(),
          12.verticalSpace,
          const AssetListItemSkeleton(),
          12.verticalSpace,
          const AssetListItemSkeleton(),
        ],
      );
    }

    return Column(
      children: [
        if (controller.stockAssets.isNotEmpty)
          ...controller.stockAssets.map((asset) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildAssetItem(asset),
          )),
      ],
    );
  }

  Widget _buildCryptoContent() {
    if (controller.isLoading.value) {
      return Column(
        children: [
          const AssetListItemSkeleton(),
          12.verticalSpace,
          const AssetListItemSkeleton(),
          12.verticalSpace,
          const AssetListItemSkeleton(),
        ],
      );
    }

    return Column(
      children: [
        if (controller.cryptoAssets.isNotEmpty)
          ...controller.cryptoAssets.map((asset) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildAssetItem(asset),
          )),
      ],
    );
  }

  Widget _buildMacroContent() {
    if (controller.isLoading.value) {
      return Column(
        children: [
          const AssetListItemSkeleton(),
          12.verticalSpace,
          const AssetListItemSkeleton(),
          12.verticalSpace,
          const AssetListItemSkeleton(),
        ],
      );
    }

    return Column(
      children: [
        if (controller.macroAssets.isNotEmpty)
          ...controller.macroAssets.map((asset) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildAssetItem(asset),
          )),
      ],
    );
  }

  Widget _buildFavoritesContent() {
    if (controller.isLoading.value) {
      return Column(
        children: [
          const AssetListItemSkeleton(),
          12.verticalSpace,
          const AssetListItemSkeleton(),
          12.verticalSpace,
          const AssetListItemSkeleton(),
        ],
      );
    }

    if (controller.favoriteAssets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

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

    return Column(
      children: [
        ...controller.favoriteAssets.map((asset) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildAssetItem(asset),
        )),
      ],
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