import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/colors.dart';

import '../core/constants/images.dart';
import '../view/favourite/favourite_screen.dart';
import '../view/forcast/forcast_screen.dart';
import '../view/home/home_screen.dart';
import '../view/settings/setting_screen.dart';
import '../view/trend/trend_screen.dart';


class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
     HomeScreen(),
    const ForcastScreen(),
    const TrendScreen(),
    const FavouriteScreen(showBackButton: false),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      backgroundColor: AppColors.kscoffald,
      floatingActionButton: Container(
        margin: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 7.h,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.r),
          child: Container(
            height: 64.h,
            decoration: BoxDecoration(
              color: AppColors.kscoffald,
              borderRadius: BorderRadius.circular(100.r),
              border: Border.all(
                color: AppColors.kwhite.withValues(alpha: 0.16),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFloatingNavItem(0, AppImages.home),
                  _buildFloatingNavItem(1, AppImages.forcast),
                  _buildFloatingNavItem(2, AppImages.trend),
                  _buildFloatingNavItem(3, AppImages.favourite),
                  _buildFloatingNavItem(4, AppImages.setting),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFloatingNavItem(int index, String svgIcon) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with fixed container height for consistent centering
            SizedBox(
              height: 24.h,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: SvgPicture.asset(
                  svgIcon,
                  key: ValueKey('${isSelected}_$index'),
                  width: isSelected ? 24.r : 22.r,
                  height: isSelected ? 24.r : 22.r,
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppColors.kprimary : AppColors.kwhite.withValues(alpha: 0.6),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            // Indicator with consistent positioning
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 16.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.kprimary : Colors.transparent,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative Floating Design with Pills using SVG
class FloatingPillNavBar extends StatefulWidget {
  const FloatingPillNavBar({super.key});

  @override
  State<FloatingPillNavBar> createState() => _FloatingPillNavBarState();
}

class _FloatingPillNavBarState extends State<FloatingPillNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
     HomeScreen(),
    const ForcastScreen(),
    const TrendScreen(),
    const FavouriteScreen(showBackButton: false),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 7.h,
            child: Container(
              height: 64.h,
              decoration: BoxDecoration(
                color: AppColors.kscoffald.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(
                  color: AppColors.kwhite.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 50,
                    offset: const Offset(0, 25),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPillNavItem(0, AppImages.home),
                        _buildPillNavItem(1, AppImages.forcast),
                        _buildPillNavItem(2, AppImages.trend),
                        _buildPillNavItem(3, AppImages.favourite),
                        _buildPillNavItem(4, AppImages.setting),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.kscoffald,
    );
  }

  Widget _buildPillNavItem(int index, String svgIcon) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with fixed container height for consistent centering
            SizedBox(
              height: 28.h,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: SvgPicture.asset(
                  svgIcon,
                  key: ValueKey('${isSelected}_$index'),
                  width: isSelected ? 28.r : 24.r,
                  height: isSelected ? 28.r : 24.r,
                  colorFilter: isSelected ? ColorFilter.mode(
                    AppColors.kprimary,
                    BlendMode.srcIn,
                  ) : null,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            // Indicator with consistent positioning
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 16.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.kprimary : null,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}