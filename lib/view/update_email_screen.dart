import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:forcast/widgets/custom_button.dart';
import 'package:forcast/widgets/custom_textfield.dart';
import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';

class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({super.key});

  @override
  State<UpdateEmailScreen> createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final TextEditingController _registeredEmailController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the registered email
    _registeredEmailController.text = 'ruslan@gmail.com';
    _newEmailController.text = 'ruslan@gmail.com';
  }

  @override
  void dispose() {
    _registeredEmailController.dispose();
    _newEmailController.dispose();
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
                  Text(
                    'Update Email',
                    style: AppTextStyles.ktwhite16500,
                  ),
                  SizedBox(width: 24.w),
                ],
              ),
              21.verticalSpace,
              
              // Description Text
              Text(
                "Enter your new email address below. We'll send you a one-time passcode (OTP) to reset your email.",
                style: AppTextStyles.kwhite14400
              ),
              25.verticalSpace,
              CustomTextFormField(
                  hintName: "Registered Email",
                  titleofTestFormField: "Your Registered Email",
                  controller: _registeredEmailController,
              ),
              25.verticalSpace,
              CustomTextFormField(
                hintName: "New Email",
                titleofTestFormField: "Your New Email",
                controller: _newEmailController,
              ),
              21.verticalSpace,
              
              // Send OTP Code Button
              CustomButton(
                text: 'Send OTP Code',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('OTP code sent successfully!'),
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