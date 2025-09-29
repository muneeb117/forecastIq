import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';

/// Centralized helper class for user messaging operations
/// Provides consistent snackbar, dialog, and notification methods
class MessageHelper {
  MessageHelper._();

  /// Show success message
  static void showSuccess(String message, {String? title, Duration? duration}) {
    Get.snackbar(
      title ?? '✅ Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.kgreen.withOpacity(0.1),
      colorText: AppColors.kgreen,
      duration: duration ?? const Duration(seconds: 3),
      margin: EdgeInsets.all(16.w),
      borderRadius: 8.r,
      icon: Icon(
        Icons.check_circle,
        color: AppColors.kgreen,
        size: 24.r,
      ),
    );
  }

  /// Show error message
  static void showError(String message, {String? title, Duration? duration}) {
    Get.snackbar(
      title ?? '❌ Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.kred.withOpacity(0.1),
      colorText: AppColors.kred,
      duration: duration ?? const Duration(seconds: 4),
      margin: EdgeInsets.all(16.w),
      borderRadius: 8.r,
      icon: Icon(
        Icons.error,
        color: AppColors.kred,
        size: 24.r,
      ),
    );
  }

  /// Show warning message
  static void showWarning(String message, {String? title, Duration? duration}) {
    Get.snackbar(
      title ?? '⚠️ Warning',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.kyellow.withOpacity(0.1),
      colorText: AppColors.kyellow,
      duration: duration ?? const Duration(seconds: 3),
      margin: EdgeInsets.all(16.w),
      borderRadius: 8.r,
      icon: Icon(
        Icons.warning,
        color: AppColors.kyellow,
        size: 24.r,
      ),
    );
  }

  /// Show info message
  static void showInfo(String message, {String? title, Duration? duration}) {
    Get.snackbar(
      title ?? 'ℹ️ Info',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.kprimary.withOpacity(0.1),
      colorText: AppColors.kprimary,
      duration: duration ?? const Duration(seconds: 3),
      margin: EdgeInsets.all(16.w),
      borderRadius: 8.r,
      icon: Icon(
        Icons.info,
        color: AppColors.kprimary,
        size: 24.r,
      ),
    );
  }

  /// Show loading message
  static void showLoading(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Loading...',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.kwhite2.withOpacity(0.1),
      colorText: AppColors.kwhite,
      duration: const Duration(seconds: 30), // Long duration for loading
      margin: EdgeInsets.all(16.w),
      borderRadius: 8.r,
      showProgressIndicator: true,
      icon: SizedBox(
        width: 24.r,
        height: 24.r,
        child: CircularProgressIndicator(
          color: AppColors.kprimary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Show custom snackbar with color
  static void showCustom({
    required String title,
    required String message,
    required Color color,
    IconData? icon,
    Duration? duration,
    SnackPosition? position,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position ?? SnackPosition.TOP,
      backgroundColor: color.withOpacity(0.1),
      colorText: color,
      duration: duration ?? const Duration(seconds: 3),
      margin: EdgeInsets.all(16.w),
      borderRadius: 8.r,
      icon: icon != null
          ? Icon(
              icon,
              color: color,
              size: 24.r,
            )
          : null,
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