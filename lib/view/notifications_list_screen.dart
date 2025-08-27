import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';

class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'Lorem Ipsem',
      description: 'Lorem ipsum is a dummy text, use for placeholders.',
      time: '29 November 2021 (13.00)',
      icon: '₿',
      iconColor: Colors.orange,
    ),
    NotificationItem(
      title: 'Lorem Ipsem',
      description: 'Lorem ipsum is a dummy text, use for placeholders.',
      time: '29 November 2021 (13.00)',
      icon: '⚠',
      iconColor: Colors.amber,
    ),
    NotificationItem(
      title: 'Lorem Ipsem',
      description: 'Lorem ipsum is a dummy text, use for placeholders.',
      time: '29 November 2021 (13.00)',
      icon: '✓',
      iconColor: Colors.green,
      isRead: true,
    ),
    NotificationItem(
      title: 'Lorem Ipsem',
      description: 'Lorem ipsum is a dummy text, use for placeholders.',
      time: '29 November 2021 (13.00)',
      icon: '✗',
      iconColor: Colors.red,
    ),
  ];

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
                    'Notifications',
                    style: AppTextStyles.ktwhite16500,
                  ),
                  SizedBox(width: 24.w),
                ],
              ),
              30.verticalSpace,
              
              // Notifications List
              Expanded(
                child: ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationCard(notification, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.ktertiary,
        borderRadius: BorderRadius.circular(12.r),
        border: notification.isRead 
            ? null 
            : Border.all(
                color: AppColors.kprimary.withOpacity(0.3),
                width: 1,
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: notification.iconColor,
            ),
            child: Center(
              child: Text(
                notification.icon,
                style: AppTextStyles.kwhite16600.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.kwhite,
                ),
              ),
            ),
          ),
          16.horizontalSpace,
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  notification.title,
                  style: AppTextStyles.ktwhite16600,
                ),
                8.verticalSpace,
                
                // Description
                Text(
                  notification.description,
                  style: AppTextStyles.ktwhite14400.copyWith(
                    color: AppColors.kwhite2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                8.verticalSpace,
                
                // Time
                Text(
                  notification.time,
                  style: AppTextStyles.ktwhite12500.copyWith(
                    color: AppColors.kwhite2,
                  ),
                ),
              ],
            ),
          ),
          
          // Read/Unread indicator
          if (!notification.isRead)
            Container(
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.kprimary,
              ),
            ),
        ],
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String description;
  final String time;
  final String icon;
  final Color iconColor;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });
}