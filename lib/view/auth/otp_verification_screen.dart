import '../../core/helpers/message_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/view/Auth/reset_password_screen.dart';
import 'package:forcast/view/Auth/login_screen.dart';
import 'package:get/get.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/images.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/otp_box.dart';
import '../../services/auth_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String otpType; // 'signup', 'recovery', 'email_change'
  final String? title;
  final String? description;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.otpType,
    this.title,
    this.description,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  List<TextEditingController> otpControllers =
  List.generate(6, (index) => TextEditingController()); // 6 digits for Supabase OTP
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  int secondsRemaining = 60;
  bool canResend = false;
  final AuthService _authService = AuthService.instance;
  bool _isVerifying = false;

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

  Future<void> _handleVerifyOTP() async {
    String otp = otpControllers
        .map((controller) => controller.text)
        .join();

    if (otp.length != 6) {
      MessageHelper.showError(
        'Please enter a valid 6-digit OTP',
      );
      return;
    }

    bool success = false;

    switch (widget.otpType) {
      case 'signup':
        success = await _authService.verifySignupOTP(
          email: widget.email,
          otp: otp,
        );
        if (success) {
          // Navigate to login screen
          Get.offAll(() => const LoginScreen());
        }
        break;

      case 'recovery':
        success = await _authService.verifyPasswordResetOTP(
          email: widget.email,
          otp: otp,
        );
        if (success) {
          // Navigate to reset password screen
          Get.to(() => const ResetPasswordScreen());
        }
        break;

      case 'email_change':
        success = await _authService.verifyEmailUpdateOTP(
          email: widget.email,
          otp: otp,
        );
        if (success) {
          // Navigate back to profile/settings
          Get.back();
          Get.back(); // Go back twice to return to settings
        }
        break;

      default:
        MessageHelper.showError(
          'Invalid OTP type',
        );
    }
  }

  Future<void> _handleResendOTP() async {
    final success = await _authService.resendOTP(
      email: widget.email,
      type: widget.otpType,
    );

    if (success) {
      setState(() {
        secondsRemaining = 60;
        canResend = false;
        // Clear existing OTP inputs
        for (var controller in otpControllers) {
          controller.clear();
        }
      });
      startTimer();
    }
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
                widget.description ?? "Check your email inbox or spam folder for a 6-digit one-time passcode (OTP). Enter the code below.",
                style: AppTextStyles.kblack14700.copyWith(
                  color: AppColors.kwhite,
                ),
              ),
              26.verticalSpace,

              // OTP Input Boxes (6 digits)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
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
                  onTap: _handleResendOTP,
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
              Obx(() => CustomButton(
                text: _authService.isLoading.value ? 'Verifying...' : 'Confirm',
                onPressed: _authService.isLoading.value
                    ? () {} // Disabled state - empty function
                    : () {
                        _handleVerifyOTP();
                      },
                color: AppColors.kprimary,
                backgroundColor: AppColors.kprimary,
                width: double.infinity,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
