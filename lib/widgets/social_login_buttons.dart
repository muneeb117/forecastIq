import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forcast/widgets/bottom_nav_bar.dart';
import 'package:get/get.dart';

import '../core/constants/colors.dart';
import '../core/constants/images.dart';
import '../services/auth_service.dart';
import 'custom_button.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();

    return Column(
      children: [
        Obx(() => CustomButton2(
              text: "Continue with Google",
              onPressed: authService.isLoading.value
                  ? () {}
                  : () async {
                      final response = await authService.signInWithGoogle();
                      if (response != null && response.user != null) {
                        Get.offAll(() => BottomNavBar());
                      }
                    },
              color: AppColors.ksecondary,
              backgroundColor: AppColors.ksecondary,
              width: double.infinity,
              svgIcon: AppImages.google,
              borderColor: AppColors.kwhite.withOpacity(0.2),
            )),
        8.verticalSpace,
        if (Platform.isIOS) ...[
          Obx(() => CustomButton2(
                text: "Continue with Apple",
                onPressed: authService.isLoading.value
                    ? () {}
                    : () async {
                        final response = await authService.signInWithApple();
                        if (response != null && response.user != null) {
                          Get.offAll(() => BottomNavBar());
                        }
                      },
                color: AppColors.ksecondary,
                backgroundColor: AppColors.ksecondary,
                width: double.infinity,
                svgIcon: AppImages.apple,
                borderColor: AppColors.kwhite.withOpacity(0.2),
              )),
        ],
      ],
    );
  }
}
