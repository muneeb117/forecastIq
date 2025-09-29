import '../../core/helpers/message_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../core/constants/images.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../services/auth_service.dart';
import '../auth/otp_verification_screen.dart';

class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({super.key});

  @override
  State<UpdateEmailScreen> createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final TextEditingController _registeredEmailController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    // Pre-fill the current email
    _registeredEmailController.text = _authService.userEmail ?? '';
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
                  isEditable: false,
              ),
              25.verticalSpace,
              CustomTextFormField(
                hintName: "New Email",
                titleofTestFormField: "Your New Email",
                controller: _newEmailController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an email address';
                  }
                  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              21.verticalSpace,
              
              // Update Email Button
              Obx(() => CustomButton(
                text: _authService.isLoading.value ? 'Updating...' : 'Update Email',
                onPressed: _authService.isLoading.value ? () {} : () async {
                  final newEmail = _newEmailController.text.trim();

                  if (newEmail.isEmpty) {
                    MessageHelper.showError(
                      'Please enter a new email address',
                    );
                    return;
                  }

                  // Email validation regex
                  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(newEmail)) {
                    MessageHelper.showError(
                      'Please enter a valid email address',
                    );
                    return;
                  }

                  if (newEmail == _authService.userEmail) {
                    MessageHelper.showError(
                      'New email must be different from current email',
                    );
                    return;
                  }

                  final success = await _authService.updateEmail(newEmail: newEmail);

                  if (success) {
                    // Navigate to OTP verification screen
                    Get.to(() => OTPVerificationScreen(
                      email: newEmail,
                      otpType: 'email_change',
                      title: 'Verify New Email',
                      description: 'We sent a 6-digit verification code to $newEmail. Please enter it below to confirm your email change.',
                    ));
                  }
                },
                color: AppColors.kprimary,
                textStyle: AppTextStyles.kwhite16700,
              )),
            ],
          ),
        ),
      ),
    );
  }
}