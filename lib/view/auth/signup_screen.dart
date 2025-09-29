
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_form.dart';
import '../../widgets/auth_switch_link.dart';
import '../../widgets/or_divider.dart';
import '../../widgets/social_login_buttons.dart';
import 'otp_verification_screen.dart';

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
  final AuthService _authService = Get.find<AuthService>();

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
                Obx(() => AuthForm(
                  isLogin: false,
                  formKey: _formKey,
                  emailController: emailController,
                  passwordController: passwordController,
                  fullNameController: fullNameController,
                  confirmPasswordController: confirmPasswordController,
                  isLoading: _authService.isLoading.value,
                  onSubmitted: () async {
                    if (_formKey.currentState!.validate()) {
                      final response = await _authService.signUp(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                        fullName: fullNameController.text.trim(),
                      );

                      if (response != null && response.user != null) {
                        Get.to(() => OTPVerificationScreen(
                              email: emailController.text.trim(),
                              otpType: 'signup',
                              title: 'Verify Email',
                              description:
                                  'We sent a 6-digit verification code to ${emailController.text.trim()}. Please enter it below to complete your registration.',
                            ));
                      }
                    }
                  },
                )),
                18.verticalSpace,
                const OrDivider(),
                16.verticalSpace,
                const SocialLoginButtons(),
                16.verticalSpace,
                const AuthSwitchLink(isLogin: false),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
