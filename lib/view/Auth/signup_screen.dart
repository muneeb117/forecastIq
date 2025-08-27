import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/images.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Forecast',
                          style: AppTextStyles.kwhite24500,
                        ),
                        TextSpan(
                          text: 'IQ',
                          style: AppTextStyles.kwhite24500.copyWith(
                            color: AppColors.kprimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  8.verticalSpace,
          
                  Text(
                    'AI-Powered Market Forecasting',
                    style: AppTextStyles.kwhite14400,
                  ),
                  18.verticalSpace,
          
                  Text('Join Us Today', style: AppTextStyles.kwhite18700),
                  18.verticalSpace,
                  CustomTextFormField(
                    hintName: "Your full name",
                    titleofTestFormField: "Full Name",
                    controller: fullNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
          
                  13.verticalSpace,
          
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
          
                  13.verticalSpace,
          
                  CustomTextFormField(
                    hintName: "••••••••••••",
                    titleofTestFormField: "Confirm Password",
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
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
          
                  18.verticalSpace,
          
                  // Sign Up Button
                  CustomButton(
                    text: 'Sign up',
                    onPressed: () {
                      // if (_formKey.currentState!.validate()) {
                      //   // Handle sign up
                      // }
                      Get.to(()=>BottomNavBar());
                    },
                    color: AppColors.kprimary,
                    backgroundColor: AppColors.kprimary,
                    width: double.infinity,
                  ),
          
                  18.verticalSpace,
          
                  // Divider with "or"
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: AppColors.ksecwhite),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'or',
                          style: AppTextStyles.kblack14700.copyWith(
                            color: AppColors.kgrey6,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: AppColors.ksecwhite),
                      ),
                    ],
                  ),
          
                  16.verticalSpace,
          
                  // Google Sign In Button
                  CustomButton2(
                    text: "Continue with Google",
                    onPressed: () {},
                    color: AppColors.ksecondary,
                    backgroundColor: AppColors.ksecondary,
                    width: double.infinity,
                    svgIcon: AppImages.google,
                    borderColor: AppColors.kwhite.withOpacity(0.2),
                  ),
                  8.verticalSpace,
          
                  // Apple Sign In Button
                  CustomButton2(
                    text: "Continue with Apple",
                    onPressed: () {},
                    color: AppColors.ksecondary,
                    backgroundColor: AppColors.ksecondary,
                    width: double.infinity,
                    svgIcon: AppImages.apple,
                    borderColor: AppColors.kwhite.withOpacity(0.2),
                  ),
          
                  16.verticalSpace,
          
                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?  ",
                        style: AppTextStyles.kwhite14400,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Text(
                          'Sign In',
                          style: AppTextStyles.kblack14700.copyWith(
                            color: AppColors.kprimary,
                          ),
                        ),
                      ),
                    ],
                  ),
          
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
