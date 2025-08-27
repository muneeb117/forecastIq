import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/view/Auth/otp_verification_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/images.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Text("Forgot Your Password?",
                      style: AppTextStyles.kblack18500.copyWith(
                        color: AppColors.kwhite
                      )
                    ),
                    SizedBox()
                  ],
                ),

                15.verticalSpace,

                // Description
                Text(
                  "Enter your registered email address below. We'll send you a one-time passcode (OTP) to reset your password.",
                  style: AppTextStyles.kwhite14400
                ),
                26.verticalSpace,

                // Email Field
                CustomTextFormField(
                  hintName: "Email",
                  titleofTestFormField: "Your Registered Email",
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

               21.verticalSpace,

                // Send OTP Button
                CustomButton(
                  text: 'Send OTP Code',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Get.to(() => const OTPVerificationScreen());
                    }
                  },
                  color: AppColors.kprimary,
                  backgroundColor: AppColors.kprimary,
                  width: double.infinity,
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
