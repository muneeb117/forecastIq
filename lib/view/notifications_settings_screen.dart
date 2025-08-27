import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:forcast/widgets/custom_button.dart';
import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';
import 'alerts_frequency_screen.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundVibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
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
                  Text(
                    'Notifications Settings',
                    style: AppTextStyles.ktwhite16500,
                  ),
                  SizedBox(width: 24.w),
                ],
              ),
              22.verticalSpace,
              
              // Notifications Toggle
              Container(
                height: 54.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.h),
                decoration: BoxDecoration(
                  color: AppColors.ktertiary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: AppTextStyles.kmwhite16600,
                    ),
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      activeColor: AppColors.kwhite,
                      activeTrackColor: AppColors.kprimary,
                      inactiveThumbColor: AppColors.kwhite2,
                      inactiveTrackColor: AppColors.kgrey,
                    ),
                  ],
                ),
              ),
              12.verticalSpace,
              
              // Sound & Vibration Toggle
              Container(
                height: 54.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.ktertiary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sound & Vibration',
                      style: AppTextStyles.kmwhite16600,
                    ),
                    Switch(
                      value: _soundVibrationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundVibrationEnabled = value;
                        });
                      },
                      activeColor: AppColors.kwhite,
                      activeTrackColor: AppColors.kprimary,
                      inactiveThumbColor: AppColors.kwhite2,
                      inactiveTrackColor: AppColors.kgrey,
                    ),
                  ],
                ),
              ),
              12.verticalSpace,
              
              // Set Up Alerts & Frequency Option
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlertsFrequencyScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.ktertiary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Set Up Alerts & Frequency',
                        style: AppTextStyles.kmwhite16600,
                      ),
                      SvgPicture.asset(
                        AppImages.forward,
                        width: 18.w,
                        height: 18.h,
                        color: AppColors.kwhite,
                      ),
                    ],
                  ),
                ),
              ),
              12.verticalSpace,
              
              // Test Alerts Button
              CustomButton(
                text: 'Test Alerts',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test alert sent!'),
                    ),
                  );
                },
                color: AppColors.kprimary,
                textStyle: AppTextStyles.kwhite16700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}