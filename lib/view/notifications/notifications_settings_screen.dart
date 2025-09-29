import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:forcast/widgets/custom_button.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../services/notification_service.dart';
import './alerts_frequency_screen.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  final NotificationService _notificationService = Get.find<NotificationService>();

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

                        if (value) {
                          Get.snackbar(
                            '🔔 Notifications Enabled',
                            'You will now receive crypto alerts and updates',
                            snackPosition: SnackPosition.TOP,
                          );
                        } else {
                          Get.snackbar(
                            '🔕 Notifications Disabled',
                            'All notifications have been turned off',
                            snackPosition: SnackPosition.TOP,
                          );
                          _notificationService.clearAllNotifications();
                        }
                      },
                      activeThumbColor: AppColors.kwhite,
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

                        if (value) {
                          Get.snackbar(
                            '🔊 Sound & Vibration On',
                            'Notifications will play sound and vibrate',
                            snackPosition: SnackPosition.TOP,
                          );
                        } else {
                          Get.snackbar(
                            '🔇 Sound & Vibration Off',
                            'Notifications will be silent',
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      activeThumbColor: AppColors.kwhite,
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
                onPressed: () => _testAllAlerts(),
                color: AppColors.kprimary,
                textStyle: AppTextStyles.kwhite16700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _testAllAlerts() {
    if (!_notificationsEnabled) {
      Get.snackbar(
        '❌ Notifications Disabled',
        'Please enable notifications first to test alerts',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Show immediate test notification
    _notificationService.showNotification(
      title: '✅ Test Alert Success!',
      body: _soundVibrationEnabled
        ? 'This is how your notifications will look, sound and vibrate'
        : 'This is how your notifications will look (sound & vibration off)',
    );

    // Schedule different types of test alerts
    _testScheduledAlerts();
  }

  void _testScheduledAlerts() {
    // Price alert test (5 seconds)
    _notificationService.scheduleNotification(
      title: '🚨 Bitcoin Price Alert',
      body: 'Bitcoin has reached \$45,000 - Your target price!',
      delay: const Duration(seconds: 5),
    );

  }
}