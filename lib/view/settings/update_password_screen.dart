import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../core/constants/images.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../services/auth_service.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                  Text('Update Password', style: AppTextStyles.ktwhite16500),
                  SizedBox(width: 24.w),
                ],
              ),
              20.verticalSpace,

              CustomTextFormField(
                hintName: 'Current Password',
                titleofTestFormField: 'Current Password',
                controller: _passwordController,
                isPassword: true,
                maxLines: 1,
              ),
              16.verticalSpace,

              CustomTextFormField(
                hintName: 'New Password',
                titleofTestFormField: 'New Password',
                controller: _newPasswordController,
                isPassword: true,
                maxLines: 1,
              ),
              16.verticalSpace,

              CustomTextFormField(
                hintName: 'Confirm New Password',
                titleofTestFormField: 'Confirm New Password',
                controller: _confirmPasswordController,
                isPassword: true,
                maxLines: 1,
              ),
              16.verticalSpace,

              // Password Requirements Text
              Text(
                'Your password needs to be at least 8 characters long. Include some words and phrases to make it even safer.',
                style: AppTextStyles.kwhite14400,
              ),
              32.verticalSpace,

              // Update Button
              Obx(() => CustomButton(
                text: _authService.isLoading.value ? 'Updating...' : 'Update Password',
                onPressed: _authService.isLoading.value ? () {} : () async {
                  final currentPassword = _passwordController.text.trim();
                  final newPassword = _newPasswordController.text.trim();
                  final confirmPassword = _confirmPasswordController.text.trim();

                  if (currentPassword.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Please enter your current password',
                      snackPosition: SnackPosition.TOP,
                    );
                    return;
                  }

                  if (newPassword.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Please enter a new password',
                      snackPosition: SnackPosition.TOP,
                    );
                    return;
                  }

                  if (newPassword.length < 8) {
                    Get.snackbar(
                      'Error',
                      'Password must be at least 8 characters long',
                      snackPosition: SnackPosition.TOP,
                    );
                    return;
                  }

                  if (newPassword != confirmPassword) {
                    Get.snackbar(
                      'Error',
                      'New password and confirmation do not match',
                      snackPosition: SnackPosition.TOP,
                    );
                    return;
                  }

                  if (newPassword == currentPassword) {
                    Get.snackbar(
                      'Error',
                      'New password must be different from current password',
                      snackPosition: SnackPosition.TOP,
                    );
                    return;
                  }

                  final success = await _authService.updatePassword(newPassword: newPassword);

                  if (success) {
                    Navigator.pop(context);
                  }
                },
                color: AppColors.kprimary,
                textStyle: AppTextStyles.kwhite16700,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
