import 'package:flutter/material.dart';
import 'package:forcast/view/Auth/login_screen.dart';
import 'package:forcast/view/Auth/signup_screen.dart';
import 'package:get/get.dart';

import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';

class AuthSwitchLink extends StatelessWidget {
  final bool isLogin;

  const AuthSwitchLink({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? "I'm new to ForecastIQ  " : "Already have an account?  ",
          style: AppTextStyles.kwhite14400,
        ),
        GestureDetector(
          onTap: () {
            if (isLogin) {
              Get.to(() => SignupScreen());
            } else {
              Get.to(() => LoginScreen());
            }
          },
          child: Text(
            isLogin ? 'Sign up' : 'Sign In',
            style: AppTextStyles.kblack14700.copyWith(
              color: AppColors.kprimary,
            ),
          ),
        ),
      ],
    );
  }
}
