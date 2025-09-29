
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final AuthService _authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      appBar: AppBar(
        title: const Text('Delete Account',
            style: TextStyle(
              color: AppColors.kwhite,
            )
        ),
        backgroundColor: AppColors.kscoffald,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.kwhite,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              30.verticalSpace,
              Text(
                'Are you sure you want to\ndelete your account?',
                textAlign: TextAlign.center,
                style: AppTextStyles.kwhite18700,
              ),
              12.verticalSpace,
              Text(
                'This action is irreversible. All your data will be permanently deleted.',
                textAlign: TextAlign.center,
                style: AppTextStyles.kwhite14400,
              ),
              30.verticalSpace,
              Obx(() => CustomButton2(
                text: _authService.isLoading.value ? "Deleting..." : "Delete Account",
                onPressed: _authService.isLoading.value ? () {} : () async {
                  await _authService.deleteAccount();
                  Get.offAll(() => const LoginScreen());
                },
                color: AppColors.kred,
                textStyle: AppTextStyles.kblack14700.copyWith(
                  color: AppColors.kwhite,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
