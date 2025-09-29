import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.ksecwhite,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'or',
            style: AppTextStyles.kblack14700.copyWith(color: AppColors.kgrey6),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.ksecwhite,
          ),
        ),
      ],
    );
  }
}
