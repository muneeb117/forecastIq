import '../../core/helpers/message_helper.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../core/constants/images.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _emailController.text = _authService.userEmail ?? '';
    _nameController.text = _authService.userName ?? '';
  }

  Future<void> _pickImage() async {
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.ksecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) => Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Profile Picture',
                style: AppTextStyles.ktwhite16600,
              ),
              20.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? image = await _picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() {
                          _selectedImage = File(image.path);
                        });
                      }
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() {
                          _selectedImage = File(image.path);
                        });
                      }
                    },
                  ),
                ],
              ),
              20.verticalSpace,
            ],
          ),
        ),
      );
    } catch (e) {
      MessageHelper.showError(
        'Failed to pick image: $e',
      );
    }
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: AppColors.kprimary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.kwhite,
              size: 30.r,
            ),
          ),
          10.verticalSpace,
          Text(
            label,
            style: AppTextStyles.ktwhite14500,
          ),
        ],
      ),
    );
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.r),
                            child: Obx(() {
                              final profileImageUrl = _authService.userProfileImage;

                              if (_selectedImage != null) {
                                return Image.file(
                                  _selectedImage!,
                                  width: 100.w,
                                  height: 100.h,
                                  fit: BoxFit.cover,
                                );
                              } else if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
                                return Image.network(
                                  profileImageUrl,
                                  width: 100.w,
                                  height: 100.h,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.kwhite,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    final userName = _authService.userName ?? 'User';
                                    final initials = userName.split(' ')
                                        .map((name) => name.isNotEmpty ? name[0].toUpperCase() : '')
                                        .take(2)
                                        .join('');
                                    return Center(
                                      child: Text(
                                        initials.isNotEmpty ? initials : 'U',
                                        style: AppTextStyles.ktwhite16600.copyWith(
                                          fontSize: 32.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                final userName = _authService.userName ?? 'User';
                                final initials = userName.split(' ')
                                    .map((name) => name.isNotEmpty ? name[0].toUpperCase() : '')
                                    .take(2)
                                    .join('');
                                return Center(
                                  child: Text(
                                    initials.isNotEmpty ? initials : 'U',
                                    style: AppTextStyles.ktwhite16600.copyWith(
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                            }),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 32.w,
                              height: 32.h,
                              decoration: BoxDecoration(
                                color: AppColors.ktertiary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.kwhite,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(AppImages.camera,
                                width: 16.w,
                                height: 16.h,
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
                    isEditable: false,
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: SvgPicture.asset(
                        AppImages.email,
                        width: 20.w,
                        height: 20.h,
                        colorFilter: ColorFilter.mode(
                          AppColors.kwhite.withValues(alpha: 0.6),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  15.verticalSpace,
                  Obx(() => CustomButton(
                    text: _authService.isLoading.value ? "Updating..." : "Update",
                    onPressed: _authService.isLoading.value ? () {} : () async {
                      final success = await _authService.updateProfile(
                        fullName: _nameController.text.trim(),
                        profileImage: _selectedImage,
                      );

                      if (success) {
                        setState(() {
                          _selectedImage = null;
                        });
                      }
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