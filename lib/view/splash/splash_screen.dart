import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:get/get.dart';


import '../../core/constants/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() {
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        final authService = Get.find<AuthService>();
        if (authService.isSignedIn) {
          Get.offAll(() => BottomNavBar());
        } else {
          Get.offAll(() => const OnBoardingScreen());
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark, // iOS: white icons
        statusBarIconBrightness: Brightness.light, // Android: white icons
        systemNavigationBarColor: AppColors.ksecondary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body:
        SafeArea(child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Forecast",
                          style: TextStyle(
                            fontFamily: 'SfProDisplay',
                            fontWeight: FontWeight.w500,
                            fontSize: 24.sp,
                            color: AppColors.kwhite,
                          ),
                        ),
                        TextSpan(
                          text: "IQ",
                          style: TextStyle(
                            fontFamily: 'SfProDisplay',
                            fontWeight: FontWeight.w500,
                            fontSize: 24.sp,
                            color: AppColors.kprimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Smarter predictions. Better decisions.",
                    style: TextStyle(
                      fontFamily: 'SfProDisplay',
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: AppColors.kwhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              "Version 1.0.0",
              style: TextStyle(
                fontFamily: 'SfProDisplay',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                color: AppColors.kgrey,
              ),
            ),
          ),
        ],
      ),
      )
      ),
    );
  }
}
