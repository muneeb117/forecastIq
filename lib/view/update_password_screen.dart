import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:forcast/widgets/custom_button.dart';
import 'package:forcast/widgets/custom_textfield.dart';
import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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

              CustomTextFormField(
                hintName: 'password',
                titleofTestFormField: '',
                controller: _passwordController,
                isPassword: true,
                maxLines: 1,
              ),
              16.verticalSpace,

              // Password Requirements Text
              Text(
                'Your password needs to be at least 8 characters long. Includes some words and phrases to make it even safer',
                style: AppTextStyles.kwhite14400,
              ),

              CustomTextFormField(
                hintName: 'New Password',
                titleofTestFormField: '',
                controller: _newPasswordController,
                isPassword: true,
                maxLines: 1,
              ),
              CustomTextFormField(
                hintName: 'Repeat your password',
                titleofTestFormField: '',
                controller: _confirmPasswordController,
                isPassword: true,
                maxLines: 1,
              ),
              32.verticalSpace,

              // Update Button
              CustomButton(
                text: 'Update',
                onPressed: () {
                  // Handle password update logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully!'),
                    ),
                  );
                },
                color: AppColors.kprimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
