import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/view/Auth/reset_password_screen.dart';
import 'package:get/get.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/images.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/otp_box.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  List<TextEditingController> otpControllers =
  List.generate(4, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());
  int secondsRemaining = 60;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
        startTimer();
      } else if (mounted) {
        setState(() {
          canResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                    "Enter OTP Code",
                    style: AppTextStyles.kblack18500.copyWith(
                      color: AppColors.kwhite,
                    ),
                  ),
                  const SizedBox(),
                ],
              ),
              22.verticalSpace,

              // Description
              Text(
                "Check your email inbox or spam folder for a one-time passcode (OTP). Enter the code below.",
                style: AppTextStyles.kblack14700.copyWith(
                  color: AppColors.kwhite,
                ),
              ),
              26.verticalSpace,

              // OTP Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                      (index) => buildOTPBox(
                    context: context,
                    index: index,
                    otpControllers: otpControllers,
                    focusNodes: focusNodes,
                  ),
                ),
              ),
              26.verticalSpace,

              // Resend Timer
              Center(
                child: canResend
                    ? GestureDetector(
                  onTap: () {
                    setState(() {
                      secondsRemaining = 60;
                      canResend = false;
                    });
                    startTimer();
                  },
                  child: Text(
                    'Resend code',
                    style: AppTextStyles.kblack14700.copyWith(
                      color: AppColors.kwhite,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.kwhite,
                    ),
                  ),
                )
                    : Text(
                  'You can resend the code in $secondsRemaining seconds',
                  style: AppTextStyles.kblack14700.copyWith(
                    color: AppColors.kwhite,
                  ),
                ),
              ),
              34.verticalSpace,

              // Confirm Button
              CustomButton(
                text: 'Confirm',
                onPressed: () {
                  String otp = otpControllers
                      .map((controller) => controller.text)
                      .join();
                  if (otp.length == 4) {
                    Get.to(() => const ResetPasswordScreen());
                  }
                },
                color: AppColors.kprimary,
                backgroundColor: AppColors.kprimary,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
