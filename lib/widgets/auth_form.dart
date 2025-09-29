import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/colors.dart';
import '../core/constants/images.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

class AuthForm extends StatelessWidget {
  final bool isLogin;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? fullNameController;
  final TextEditingController? confirmPasswordController;
  final VoidCallback onSubmitted;
  final bool isLoading;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    this.fullNameController,
    this.confirmPasswordController,
    required this.onSubmitted,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isLogin)
            CustomTextFormField(
              hintName: "Your full name",
              titleofTestFormField: "Full Name",
              controller: fullNameController!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
          if (!isLogin) 13.verticalSpace,
          CustomTextFormField(
            hintName: "Email",
            titleofTestFormField: "Email",
            controller: emailController,
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.w),
              child: SvgPicture.asset(
                AppImages.email,
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
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          13.verticalSpace,
          CustomTextFormField(
            hintName: "••••••••••••",
            titleofTestFormField: "Password",
            controller: passwordController,
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
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          if (!isLogin) 13.verticalSpace,
          if (!isLogin)
            CustomTextFormField(
              hintName: "••••••••••••",
              titleofTestFormField: "Confirm Password",
              controller: confirmPasswordController!,
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
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          18.verticalSpace,
        CustomButton(
                text: isLoading
                    ? (isLogin ? 'Signing in...' : 'Creating account...')
                    : (isLogin ? 'Sign in' : 'Sign up'),
                onPressed: isLoading ? () {} : onSubmitted,
                color: AppColors.kprimary,
                backgroundColor: AppColors.kprimary,
                width: double.infinity,
              ),
        ],
      ),
    );
  }
}
