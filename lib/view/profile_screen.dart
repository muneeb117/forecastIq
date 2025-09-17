import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:forcast/widgets/custom_button.dart';
import 'package:forcast/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _emailController.text = _authService.userEmail ?? '';
    _nameController.text = _authService.userName ?? '';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      body: SafeArea(
        child: SingleChildScrollView(
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
                          )
                      ),

                      Text(
                          'Personal Information',
                          style: AppTextStyles.ktwhite16500
                      ),
                      SizedBox()
                    ],
                  ),
                  15.verticalSpace,

                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.kprimary,
                            border: Border.all(
                              color: AppColors.kwhite.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Obx(() {
                              final userName = _authService.userName ?? 'User';
                              final initials = userName.split(' ')
                                  .map((name) => name.isNotEmpty ? name[0].toUpperCase() : '')
                                  .take(2)
                                  .join('');
                              return Text(
                                initials.isNotEmpty ? initials : 'U',
                                style: AppTextStyles.ktwhite16600.copyWith(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: GestureDetector(
                            onTap: () {

                            },
                            child: Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: AppColors.ktertiary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(AppImages.camera,
                                width: 24.w,
                                height: 24.h,
                                fit: BoxFit.contain,
                              )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  15.verticalSpace,
                  CustomTextFormField(
                    controller: _nameController,
                    hintName: "Your full name",
                    titleofTestFormField: "Full Name",
                  ),
                  12.verticalSpace,
                  CustomTextFormField(
                    controller: _emailController,
                    hintName: "Email",
                    titleofTestFormField: "Email",
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
                  ),
                  15.verticalSpace,
                  Obx(() => CustomButton(
                    text: _authService.isLoading.value ? "Updating..." : "Update",
                    onPressed: _authService.isLoading.value ? () {} : () async {
                      await _authService.updateProfile(
                        fullName: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                      );
                    },
                    color: AppColors.kprimary,
                    textStyle: AppTextStyles.kwhite16700,
                  )),

                  // Personal Information
                ]
            )
        ),
      ),
    );
  }

}