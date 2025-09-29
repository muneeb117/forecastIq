import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:forcast/view/Auth/login_screen.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../widgets/custom_button.dart';

class PasswordSuccessScreen extends StatelessWidget {
  const PasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    "Confirmation",
                    style: AppTextStyles.kblack18500.copyWith(
                      color: AppColors.kwhite,
                    ),
                  ),
                  const SizedBox(),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //const Spacer(flex: 2),

                  // Success Icon
                  SvgPicture.asset(
                    width: 105.w,
                    height: 105.h,
                    AppImages.success,
                  ),


                  28.verticalSpace,

                  Text(
                    "You're All Set!",
                    style: AppTextStyles.kblack22700.copyWith(
                      color: AppColors.kwhite
                    ),
                    textAlign: TextAlign.center,
                  ),
                  10.verticalSpace,

                  // Success Message
                  Text(
                    "Your password has been successfully updated.",
                    style: AppTextStyles.kwhite14400,
                    textAlign: TextAlign.center,
                  ),

                  150.verticalSpace,

                  // Go to Login Button
                  CustomButton(
                    text: 'Go to Log In',
                    onPressed: () {
                      // Navigate back to login screen (clear all previous screens)
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(), // Replace with your LoginScreen
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    color: AppColors.kprimary,
                    backgroundColor: AppColors.kprimary,
                    width: double.infinity,
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
              SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}