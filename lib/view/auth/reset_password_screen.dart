import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/view/Auth/password_success_screen.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/images.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/auth_service.dart';
import 'package:get/get.dart';


class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset(
                        AppImages.back,
                        width: 23.w,
                        height: 23.h,
                        colorFilter: ColorFilter.mode(
                          AppColors.kwhite,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Text(
                      "Secure Your Account",
                      style: AppTextStyles.kblack18500.copyWith(
                        color: AppColors.kwhite,
                      ),
                    ),
                    const SizedBox(),
                  ],
                ),

                24.verticalSpace,
                
                // Description
                Text(
                  "Choose a new password for your AITripBot account. Make sure it's secure and easy to remember.",
                  style: AppTextStyles.kblack14700.copyWith(
                    color: AppColors.kwhite,
                  ),
                ),

                26.verticalSpace,

                CustomTextFormField(
                  hintName: "••••••••••••",
                  titleofTestFormField: "New Password",
                  controller: newPasswordController,
                  isPassword: true,
                  maxLines: 1,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SvgPicture.asset(
                      AppImages.lock,
                      width: 20.w,
                      height: 20.h,
                      colorFilter: ColorFilter.mode(
                        AppColors.kwhite,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                
                12.verticalSpace,

                CustomTextFormField(
                  hintName: "••••••••••••",
                  titleofTestFormField: "Confirm New Password",
                  controller: confirmPasswordController,
                  isPassword: true,
                  maxLines: 1,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SvgPicture.asset(
                      AppImages.lock,
                      width: 20.w,
                      height: 20.h,
                      colorFilter: ColorFilter.mode(
                        AppColors.kwhite,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                24.verticalSpace,
                

                Obx(() => CustomButton(
                  text: _authService.isLoading.value ? 'Updating Password...' : 'Save New Password',
                  onPressed: _authService.isLoading.value ? () {} : () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await _authService.updatePassword(
                        newPassword: newPasswordController.text,
                      );

                      if (success) {
                        // Navigate to password success screen
                        Get.to(() => PasswordSuccessScreen());
                      }
                    }
                  },
                  color: AppColors.kprimary,
                  backgroundColor: AppColors.kprimary,
                  width: double.infinity,
                )),
                
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}