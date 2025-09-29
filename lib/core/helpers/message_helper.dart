import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import '../constants/colors.dart';

/// Centralized helper class for user messaging operations
/// Provides consistent snackbar, dialog, and notification methods
class MessageHelper {
  MessageHelper._();

  /// Show success message
  static void showSuccess(String message, {String? title, Duration? duration}) {
    IconSnackBar.show(
      Get.context!,
      snackBarType: SnackBarType.success,
      label: message,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Show error message
  static void showError(String message, {String? title, Duration? duration}) {
    IconSnackBar.show(
      Get.context!,
      snackBarType: SnackBarType.fail,
      label: message,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Show warning message
  static void showWarning(String message, {String? title, Duration? duration}) {
    IconSnackBar.show(
      Get.context!,
      snackBarType: SnackBarType.alert,
      label: message,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Show info message
  static void showInfo(String message, {String? title, Duration? duration}) {
    IconSnackBar.show(
      Get.context!,
      snackBarType: SnackBarType.alert,
      label: message,
      duration: duration ?? const Duration(seconds: 3),
    );
  }



  /// Show confirmation dialog
  static Future<bool?> showConfirmation({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    Color? cancelColor,
    IconData? icon,
  }) async {
    return await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.ksecondary,
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: confirmColor ?? AppColors.kprimary,
                size: 24.r,
              ),
              8.horizontalSpace,
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.kwhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: AppColors.kwhite2,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: cancelColor ?? AppColors.kwhite2,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: confirmColor ?? AppColors.kprimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation dialog
  static Future<bool?> showDeleteConfirmation({
    required String title,
    required String message,
    String deleteText = 'Delete',
    String cancelText = 'Cancel',
  }) async {
    return await showConfirmation(
      title: title,
      message: message,
      confirmText: deleteText,
      cancelText: cancelText,
      confirmColor: AppColors.kred,
      icon: Icons.delete_forever,
    );
  }

  /// Show info dialog
  static Future<void> showInfoDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
  }) async {
    await Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.ksecondary,
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: AppColors.kprimary,
                size: 24.r,
              ),
              8.horizontalSpace,
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.kwhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: AppColors.kwhite2,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              buttonText,
              style: TextStyle(
                color: AppColors.kprimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show bottom sheet message
  static Future<T?> showBottomSheet<T>({
    required Widget content,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    return await Get.bottomSheet<T>(
      Container(
        decoration: BoxDecoration(
          color: AppColors.ksecondary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: AppColors.kwhite,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close,
                        color: AppColors.kwhite2,
                        size: 24.r,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColors.kwhite2.withOpacity(0.3)),
            ],
            content,
          ],
        ),
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// Show toast-like message (short duration)
  static void showToast(String message, {Color? color}) {
    Get.rawSnackbar(
      message: message,
      duration: const Duration(seconds: 2),
      backgroundColor: color ?? AppColors.kwhite2.withOpacity(0.9),
      borderRadius: 8.r,
      margin: EdgeInsets.all(16.w),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Hide current snackbar
  static void hideSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
  }

  /// Show network error message
  static void showNetworkError() {
    showError(
      'Please check your internet connection and try again.',
      title: '🌐 Network Error',
    );
  }

  /// Show server error message
  static void showServerError() {
    showError(
      'Something went wrong on our end. Please try again later.',
      title: '🔧 Server Error',
    );
  }

  /// Show validation error message
  static void showValidationError(String field) {
    showError(
      'Please check the $field field and try again.',
      title: '📝 Validation Error',
    );
  }

  /// Show auth error message
  static void showAuthError() {
    showError(
      'Your session has expired. Please login again.',
      title: '🔐 Authentication Error',
    );
  }

  /// Show feature coming soon message
  static void showComingSoon() {
    showInfo(
      'This feature is coming soon! Stay tuned for updates.',
      title: '🚀 Coming Soon',
    );
  }

  /// Show maintenance message
  static void showMaintenance() {
    showWarning(
      'This feature is temporarily unavailable due to maintenance.',
      title: '🔧 Maintenance',
    );
  }
}