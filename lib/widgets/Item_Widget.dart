import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';
import '../core/constants/images.dart';
import '../view/coin_detail_screen.dart';

Widget buildTrendingItem(
    String? image,
    String symbol,
    String name,
    String percentage,
    bool isUp,
    String price,
    ) {
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
    child: Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.kfourth.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: image == null
                    ? AppColors.kprimary
                    : Colors.transparent,
                child: image != null
                    ? Image.asset(image)
                    : Text(
                  symbol.substring(0, 1),
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
              Spacer(),
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
                    child: Text(price, style: AppTextStyles.ktwhite14600),
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