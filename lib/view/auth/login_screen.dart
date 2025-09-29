
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forcast/widgets/bottom_nav_bar.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_form.dart';
import '../../widgets/auth_switch_link.dart';
import '../../widgets/or_divider.dart';
import '../../widgets/social_login_buttons.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'Forecast',
                        style: AppTextStyles.kwhite24500),
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
              Text(
                'Login',
                style: AppTextStyles.kwhite18700,
              ),
              18.verticalSpace,
              Obx(() => AuthForm(
                isLogin: true,
                formKey: _formKey,
                emailController: emailController,
                passwordController: passwordController,
                isLoading: _authService.isLoading.value,
                onSubmitted: () async {
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
              )),
              13.verticalSpace,
              Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.to(ForgotPasswordScreen());
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.kblack14500.copyWith(
                          color: AppColors.kwhite),
                    ),
                  ),
                ],
              ),
              18.verticalSpace,
              const OrDivider(),
              16.verticalSpace,
              const SocialLoginButtons(),
              16.verticalSpace,
              const AuthSwitchLink(isLogin: true),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}