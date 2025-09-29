import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';
import '../core/constants/images.dart';
import '../view/coin_detail/coin_detail_screen.dart';

// Helper function to format price numbers into short format
String formatPriceShort(String priceString) {
  try {
    // Handle range format like "$109198.56–$113655.64" (using en dash or hyphen)
    if (priceString.contains('–') || priceString.contains('-')) {
      final parts = priceString.contains('–')
          ? priceString.split('–')
          : priceString.split('-');

      if (parts.length == 2) {
        final lowPrice = _formatSinglePrice(parts[0]);
        final highPrice = _formatSinglePrice(parts[1]);
        return '$lowPrice–$highPrice'; // Use en dash to match original format
      }
    }

    // Handle single price
    return _formatSinglePrice(priceString);
  } catch (e) {
    return priceString; // Return original if parsing fails
  }
}

String _formatSinglePrice(String priceString) {
  print(priceString);
  // Remove $ sign and any spaces
  String cleanPrice = priceString.replaceAll('\$', '').replaceAll(',', '').trim();

  // Try to parse as double
  double? price = double.tryParse(cleanPrice);
  if (price == null) return priceString;

  // Format based on price magnitude
  if (price >= 1000000000) {
    // Billions
    return '\$${(price / 1000000000).toStringAsFixed(1)}B';
  } else if (price >= 1000000) {
    // Millions
    return '\$${(price / 1000000).toStringAsFixed(1)}M';
  } else if (price >= 1000) {
    // Thousands
    return '\$${(price / 1000).toStringAsFixed(1)}k';
  } else {
    // Less than 1000, show as is with 2 decimal places
    return '\$${price.toStringAsFixed(2)}';
  }
}

Widget buildTrendingItem(
    String? image,
    String symbol,
    String name,
    String percentage,
    bool isUp,
    String price, {
    bool isUpdating = false,
    }) {
  return GestureDetector(
    onTap: () {
      Get.to(
            () => CoinDetailScreen(
          image: image,
          symbol: symbol,
          name: name,
          percentage: percentage,
          isUp: isUp,
          price: price,
        ),
      );
    },
    child: AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.kfourth.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
        // border: isUpdating
        //     ? Border.all(color: AppColors.kprimary.withValues(alpha: 0.8), width: 2.0)
        //     : null,
        // boxShadow: isUpdating
        //     ? [
        //         BoxShadow(
        //           color: AppColors.kprimary.withValues(alpha: 0.3),
        //           blurRadius: 8.0,
        //           spreadRadius: 1.0,
        //         ),
        //       ]
        //     : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: image == null
                    ? AppColors.kprimary
                    : Colors.white,
                child: image != null
                    ? Image.asset(image,

                )
                    : Text(
                  symbol.isNotEmpty ? symbol.substring(0, 1) : '?',
                  style: AppTextStyles.ktwhite16600.copyWith(
                    color: AppColors.kwhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              16.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(symbol, style: AppTextStyles.ktwhite16600),
                    Text(name, style: AppTextStyles.ktwhite14500),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      color: isUp
                          ? AppColors.kgreen.withValues(alpha: 0.16)
                          : AppColors.kred.withValues(alpha: 0.16),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          isUp ? AppImages.up : AppImages.down,
                          width: 20.w,
                          height: 20.h,
                        ),
                        Text(
                          percentage,
                          style: AppTextStyles.ktwhite14500.copyWith(
                            color: isUp ? AppColors.kgreen : AppColors.kred,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          12.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24.h,
                    child: Text(
                      'Forecast',
                      style: AppTextStyles.ktwhite14500.copyWith(
                        color: AppColors.kwhite2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 28.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          isUp ? AppImages.up : AppImages.down,
                          width: 20.w,
                          height: 20.h,
                        ),
                        Text(
                          isUp ? "UP" : "DOWN",
                          style: AppTextStyles.ktwhite14600.copyWith(
                            color: isUp ? AppColors.kgreen : AppColors.kred,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24.h,
                    child: Text(
                      'Confidence',
                      style: AppTextStyles.ktwhite14500.copyWith(
                        color: AppColors.kwhite2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 28.h,
                    child: Text(
                      percentage,
                      style: AppTextStyles.ktwhite14600.copyWith(
                        color: isUp ? AppColors.kgreen : AppColors.kred,
                      ),
                    ),
                  ),
                ],
              ),


              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24.h,
                    child: Text(
                      'Predicted',
                      style: AppTextStyles.ktwhite14500.copyWith(
                        color: AppColors.kwhite2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 28.h,
                    child: Text(
                      formatPriceShort(price),
                      style: AppTextStyles.ktwhite14600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}