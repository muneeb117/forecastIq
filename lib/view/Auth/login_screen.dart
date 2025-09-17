import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/view/Auth/signup_screen.dart';
import 'package:forcast/widgets/bottom_nav_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/images.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/auth_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = Get.find<AuthService>();
  bool rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Forecast',
                        style: AppTextStyles.kwhite24500
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
                  style: AppTextStyles.kwhite14400
                ),
                18.verticalSpace,


                Text(
                  'Login',
                  style: AppTextStyles.kwhite18700
                ),
                18.verticalSpace,


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
                  hintName: "password",
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

                // Remember Me and Forgot Password Row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          rememberMe = !rememberMe;
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 12.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.kgrey5,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: rememberMe
                                ? Icon(
                                    Icons.check,
                                    size: 10.sp,
                                    color: AppColors.kprimary,
                                  )
                                : null,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Remember me',
                            style: AppTextStyles.kwhite14400.copyWith(
                              color: AppColors.kgrey5
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.to(ForgotPasswordScreen());
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.kblack14500.copyWith(
                          color: AppColors.kwhite
                        ),
                      ),
                    ),
                  ],
                ),

                18.verticalSpace,
                
                // Sign In Button
                Obx(() => CustomButton(
                  text: _authService.isLoading.value ? 'Signing in...' : 'Sign in',
                  onPressed: _authService.isLoading.value ? () {} : () async {
                    if (_formKey.currentState!.validate()) {
                      final response = await _authService.signIn(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                      );

                      if (response != null && response.user != null) {
                        Get.offAll(() => BottomNavBar());
                      }
                    }
                  },
                  color: AppColors.kprimary,
                  backgroundColor: AppColors.kprimary,
                  width: double.infinity,
                )),

                18.verticalSpace,
                
                // Divider with "or"
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.ksecwhite,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'or',
                        style: AppTextStyles.kblack14700.copyWith(
                          color: AppColors.kgrey6
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.ksecwhite
                      ),
                    ),
                  ],
                ),

                16.verticalSpace,
                
                // Google Sign In Button
                CustomButton2(text: "Continue with Google",
                    onPressed: (){},
                    color: AppColors.ksecondary,
                    backgroundColor: AppColors.ksecondary,
                    width: double.infinity,
                    svgIcon: AppImages.google,
                  borderColor: AppColors.kwhite.withOpacity(0.2),
                ),
                8.verticalSpace,
                
                // Apple Sign In Button
                CustomButton2(text: "Continue with Apple",
                  onPressed: (){},
                  color: AppColors.ksecondary,
                  backgroundColor: AppColors.ksecondary,
                  width: double.infinity,
                  svgIcon: AppImages.apple,
                  borderColor: AppColors.kwhite.withOpacity(0.2),
                ),

                16.verticalSpace,
                
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "I'm new to ForecastIQ  ",
                      style: AppTextStyles.kwhite14400
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(()=>SignupScreen());
                      },
                      child: Text(
                        'Sign up',
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
    );
  }
}