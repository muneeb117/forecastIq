import '../../core/helpers/message_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../services/notification_service.dart';
import '../coin_detail/coin_detail_screen.dart';

class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  final NotificationService _notificationService = Get.find<NotificationService>();

  @override
  void initState() {
    super.initState();
    // Mark all as read when opening the screen
    Future.delayed(const Duration(milliseconds: 500), () {
      _notificationService.markAllAsRead();
    });
  }

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
                  Obx(() {
                    final notifications = _notificationService.notificationHistory;
                    if (notifications.isEmpty) {
                      return SizedBox(width: 24.w, height: 24.h);
                    }

                    return GestureDetector(
                      onTap: _clearAllNotifications,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.kred.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.clear_all,
                          color: AppColors.kred,
                          size: 16.r,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              30.verticalSpace,
              
              // Notifications List
              Expanded(
                child: Obx(() {
                  final notifications = _notificationService.notificationHistory;

                  if (notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationCard(notification, index);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: AppColors.ktertiary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 40.r,
              color: AppColors.kwhite2,
            ),
          ),
          20.verticalSpace,
          Text(
            'No Notifications',
            style: AppTextStyles.kwhite18700,
          ),
          8.verticalSpace,
          Text(
            'You\'ll see your crypto alerts and\nupdates here when they arrive',
            style: AppTextStyles.ktwhite14400.copyWith(
              color: AppColors.kwhite2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationHistory notification, int index) {
    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.ktertiary,
          borderRadius: BorderRadius.circular(12.r),
          border: notification.isRead
              ? null
              : Border.all(
                  color: AppColors.kprimary.withValues(alpha: 0.3),
                  width: 1,
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin Image or Icon
            _buildNotificationIcon(notification),
            16.horizontalSpace,

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    notification.title,
                    style: AppTextStyles.ktwhite16600.copyWith(
                      color: notification.isRead
                          ? AppColors.kwhite
                          : AppColors.kprimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.verticalSpace,

                  // Description
                  Text(
                    notification.body,
                    style: AppTextStyles.ktwhite14400.copyWith(
                      color: AppColors.kwhite2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.verticalSpace,

                  Row(
                    children: [
                      // Type chip
                      _buildTypeChip(notification.type),
                      const Spacer(),
                      // Time
                      Text(
                        timeago.format(notification.timestamp),
                        style: AppTextStyles.ktwhite12500.copyWith(
                          color: AppColors.kwhite2,
                        ),
                      ),
                    ],
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
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationHistory notification) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: _getTypeColor(notification.type).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: notification.coinImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.asset(
                notification.coinImage!,
                width: 24.w,
                height: 24.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    _getTypeIcon(notification.type),
                    color: _getTypeColor(notification.type),
                    size: 20.r,
                  );
                },
              ),
            )
          : Icon(
              _getTypeIcon(notification.type),
              color: _getTypeColor(notification.type),
              size: 20.r,
            ),
    );
  }

  Widget _buildTypeChip(String type) {
    final color = _getTypeColor(type);
    final label = _getTypeLabel(type);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.kblack10600.copyWith(
          color: color,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'daily_asset_alert':
      case 'weekly_asset_alert':
      case 'realtime_asset_alert':
        return AppColors.kgreen;
      case 'price_alert':
        return AppColors.kred;
      case 'market_update':
        return AppColors.kprimary;
      case 'test_alert':
        return AppColors.kyellow;
      default:
        return AppColors.kwhite2;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'daily_asset_alert':
      case 'weekly_asset_alert':
      case 'realtime_asset_alert':
        return Icons.trending_up;
      case 'price_alert':
        return Icons.monetization_on;
      case 'market_update':
        return Icons.analytics;
      case 'test_alert':
        return Icons.science;
      default:
        return Icons.notifications;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'daily_asset_alert':
        return 'Daily Alert';
      case 'weekly_asset_alert':
        return 'Weekly Alert';
      case 'realtime_asset_alert':
        return 'Real-time';
      case 'price_alert':
        return 'Price Alert';
      case 'market_update':
        return 'Market';
      case 'test_alert':
        return 'Test';
      default:
        return 'General';
    }
  }

  void _handleNotificationTap(NotificationHistory notification) {
    // Mark as read
    _notificationService.markAsRead(notification.id);

    // Navigate to coin detail screen if it's a coin-related notification
    if (notification.coinSymbol != null) {
      Get.to(() => CoinDetailScreen(
        symbol: notification.coinSymbol!,
        name: _getCoinName(notification.coinSymbol!),
        percentage: '0%', // Default values since we don't have them in notification
        isUp: true,
        price: '0',
        image: notification.coinImage,
      ));
    } else {
      // Handle other types of notifications
      switch (notification.type) {
        case 'market_update':
          Get.toNamed('/home');
          break;
        case 'portfolio_update':
          Get.toNamed('/portfolio');
          break;
        default:
          // Show notification details in a dialog
          _showNotificationDetails(notification);
      }
    }
  }

  String _getCoinName(String symbol) {
    final coinNames = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'USDT': 'Tether',
      'XRP': 'Ripple',
      'BNB': 'Binance Coin',
      'SOL': 'Solana',
      'USDC': 'USD Coin',
      'DOGE': 'Dogecoin',
      'ADA': 'Cardano',
      'TRX': 'TRON',
    };
    return coinNames[symbol.toUpperCase()] ?? symbol;
  }

  void _clearAllNotifications() async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.ksecondary,
        title: Text(
          'Clear All Notifications',
          style: AppTextStyles.kwhite16700,
        ),
        content: Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
          style: AppTextStyles.ktwhite14400.copyWith(
            color: AppColors.kwhite2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: AppTextStyles.ktwhite14600.copyWith(
                color: AppColors.kwhite2,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Clear All',
              style: AppTextStyles.ktwhite14600.copyWith(
                color: AppColors.kred,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear all notifications
      await _notificationService.clearNotificationHistory();

      MessageHelper.showSuccess(
        'All notifications have been cleared successfully',
        title: '🗑️ Notifications Cleared',
      );
    }
  }

  void _showNotificationDetails(NotificationHistory notification) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.ksecondary,
        title: Text(
          notification.title,
          style: AppTextStyles.kwhite16700,
        ),
        content: Text(
          notification.body,
          style: AppTextStyles.ktwhite14400.copyWith(
            color: AppColors.kwhite2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: AppTextStyles.ktwhite14600.copyWith(
                color: AppColors.kprimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}