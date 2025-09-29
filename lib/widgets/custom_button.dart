import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';

/////-------------------------Button---------------------------/////

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final String? svgIcon;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.textStyle,
    this.svgIcon,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 343.w,
      height: 55.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5.0,
          backgroundColor: backgroundColor ?? color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
        ),
        onPressed: onPressed,

        child: Text(text, style: textStyle ?? AppTextStyles.kwhite16700),
      ),
    );
  }
}

class CustomButton2 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final String? svgIcon;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool? centerIcon;

  const CustomButton2({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.textStyle,
    this.svgIcon,
    this.borderRadius,
    this.padding,
    this.centerIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 56.h,
      decoration: BoxDecoration(
        color: backgroundColor ?? color,
        borderRadius: BorderRadius.circular(borderRadius ?? 100.r),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 100.r),
          ),
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (svgIcon != null && !centerIcon!) ...[
              SvgPicture.asset(svgIcon!, width: 24.w, height: 24.h),
            ],
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (svgIcon != null && centerIcon!) ...[
                    Row(
                      children: [
                        SvgPicture.asset(svgIcon!, width: 24.w, height: 24.h),
                        9.horizontalSpace,
                      ],
                    ),
                  ],
                  Text(
                    text,
                    style:
                        textStyle ??
                        AppTextStyles.kblack14500.copyWith(
                          color: AppColors.kwhite,
                        ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (svgIcon != null && !centerIcon!) ...[SizedBox()],
          ],
        ),
      ),
    );
  }
}
