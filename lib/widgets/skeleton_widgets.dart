import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../core/constants/colors.dart';

// Base Shimmer Container
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.ktertiary,
      highlightColor: AppColors.kwhite.withValues(alpha: 0.1),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.ktertiary,
          borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}

// Asset/Coin List Item Skeleton (for trending, market summary, etc.)
class AssetListItemSkeleton extends StatelessWidget {
  const AssetListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.ktertiary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Icon placeholder
          ShimmerBox(
            width: 40.r,
            height: 40.r,
            borderRadius: BorderRadius.circular(20.r),
          ),
          12.horizontalSpace,
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: 80.w,
                  height: 14.h,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                6.verticalSpace,
                ShimmerBox(
                  width: 120.w,
                  height: 12.h,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ],
            ),
          ),
          // Right side content (price, percentage, etc.)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(
                width: 60.w,
                height: 14.h,
                borderRadius: BorderRadius.circular(4.r),
              ),
              6.verticalSpace,
              ShimmerBox(
                width: 50.w,
                height: 20.h,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Forecast Card Skeleton
class ForecastCardSkeleton extends StatelessWidget {
  const ForecastCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.ktertiary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(
                width: 48.r,
                height: 48.r,
                borderRadius: BorderRadius.circular(24.r),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: 100.w,
                      height: 16.h,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    8.verticalSpace,
                    ShimmerBox(
                      width: 140.w,
                      height: 14.h,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ],
                ),
              ),
              ShimmerBox(
                width: 60.w,
                height: 28.h,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ],
          ),
          16.verticalSpace,
          ShimmerBox(
            width: double.infinity,
            height: 1.h,
            borderRadius: BorderRadius.circular(0.5.r),
          ),
          16.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: 80.w,
                    height: 12.h,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  6.verticalSpace,
                  ShimmerBox(
                    width: 100.w,
                    height: 16.h,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShimmerBox(
                    width: 60.w,
                    height: 12.h,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  6.verticalSpace,
                  ShimmerBox(
                    width: 80.w,
                    height: 16.h,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Horizontal Card Skeleton (for market cards)
class HorizontalCardSkeleton extends StatelessWidget {
  const HorizontalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.ktertiary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ShimmerBox(
                width: 32.r,
                height: 32.r,
                borderRadius: BorderRadius.circular(16.r),
              ),
              8.horizontalSpace,
              ShimmerBox(
                width: 60.w,
                height: 14.h,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ],
          ),
          12.verticalSpace,
          ShimmerBox(
            width: 80.w,
            height: 18.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
          8.verticalSpace,
          ShimmerBox(
            width: 50.w,
            height: 20.h,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ],
      ),
    );
  }
}

// List View Skeleton (multiple items)
class ListViewSkeleton extends StatelessWidget {
  final int itemCount;
  final Widget skeleton;

  const ListViewSkeleton({
    super.key,
    this.itemCount = 5,
    required this.skeleton,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: itemCount,
      separatorBuilder: (context, index) => 12.verticalSpace,
      itemBuilder: (context, index) => skeleton,
    );
  }
}

// Horizontal List Skeleton
class HorizontalListSkeleton extends StatelessWidget {
  final int itemCount;
  final Widget skeleton;

  const HorizontalListSkeleton({
    super.key,
    this.itemCount = 3,
    required this.skeleton,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (context, index) => 12.horizontalSpace,
        itemBuilder: (context, index) => skeleton,
      ),
    );
  }
}

// Profile Header Skeleton
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShimmerBox(
          width: 100.r,
          height: 100.r,
          borderRadius: BorderRadius.circular(50.r),
        ),
        16.verticalSpace,
        ShimmerBox(
          width: 150.w,
          height: 20.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
        8.verticalSpace,
        ShimmerBox(
          width: 200.w,
          height: 16.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ],
    );
  }
}

// Chart Skeleton
class ChartSkeleton extends StatelessWidget {
  final double? height;

  const ChartSkeleton({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 200.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.ktertiary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(
                width: 80.w,
                height: 14.h,
                borderRadius: BorderRadius.circular(4.r),
              ),
              ShimmerBox(
                width: 60.w,
                height: 14.h,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ],
          ),
          16.verticalSpace,
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                7,
                (index) => ShimmerBox(
                  width: 20.w,
                  height: (50 + (index * 20) % 100).h,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Text Line Skeleton
class TextLineSkeleton extends StatelessWidget {
  final double? width;
  final double? height;

  const TextLineSkeleton({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width ?? 120.w,
      height: height ?? 14.h,
      borderRadius: BorderRadius.circular(4.r),
    );
  }
}

// Grid Skeleton
class GridSkeleton extends StatelessWidget {
  final int itemCount;
  final Widget skeleton;

  const GridSkeleton({
    super.key,
    this.itemCount = 6,
    required this.skeleton,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.5,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => skeleton,
    );
  }
}