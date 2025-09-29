import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import './profile_screen.dart';
import '../favourite/favourite_screen.dart';
import '../notifications/notifications_settings_screen.dart';
import './help_faq_screen.dart';
import './term_and_condition_screen.dart';
import './privacy_policy_screen.dart';
import './about_app_screen.dart';
import './security_screen.dart';
import './delete_account_screen.dart';
import '../notifications/notifications_list_screen.dart';
import '../../core/constants/images.dart';
import '../../widgets/custom_button.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final AuthService _authService = Get.find<AuthService>();

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
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome!', style: AppTextStyles.kswhite12500),
                      Text(
                        'Settings',
                        style: AppTextStyles.kblack18500.copyWith(
                          color: AppColors.kwhite,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsListScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.ktertiary,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: SvgPicture.asset(
                        AppImages.notification,
                        width: 24.w,
                        height: 24.h,
                      ),
                    ),
                  ),
                ],
              ),
              15.verticalSpace,

              Center(
                child: Column(
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

                          if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
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
                    12.verticalSpace,
                    Obx(() => Text(
                      _authService.userName ?? "User",
                      style: AppTextStyles.kblack14700.copyWith(color: AppColors.kwhite),
                    )),
                    Obx(() => Text(
                      _authService.userEmail ?? "No email",
                      style: AppTextStyles.kwhite14400,
                    )),
                  ],
                ),
              ),
              15.verticalSpace,

              _buildSettingSection('Settings', [
                _buildSettingItem('Personal Information', AppImages.profile),
                _buildSettingItem('Favourite', AppImages.favourite),
                _buildSettingItem('Notifications', AppImages.notification),
                _buildSettingItem('Help/FAQs', AppImages.help),
                _buildSettingItem('Terms & Conditions', AppImages.terms),
                _buildSettingItem('Privacy Policy', AppImages.privacy),
                _buildSettingItem('About', AppImages.about),
                _buildSettingItem('Security', AppImages.security),

              ]),
              12.verticalSpace,
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeleteAccountScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [

                    CircleAvatar(
                        radius: 22.r,
                        backgroundColor: AppColors.kred.withOpacity(0.16),
                        child: SvgPicture.asset(
                          AppImages.delete,
                          width: 24.w,
                          height: 24.w,
                        )
                    ),
                    14.horizontalSpace,
                    Expanded(
                      child: Text(
                          "Delete Account",
                          style: AppTextStyles.kblack14700.copyWith(
                            color: AppColors.kred,
                          )
                      ),
                    ),
                  ],
                ),
              ),

              15.verticalSpace,
              Obx(() => CustomButton2(
                text: _authService.isLoading.value ? "Logging out..." : "Logout",
                onPressed: _authService.isLoading.value ? () {} : () async {
                  await _authService.signOut();
                  Get.offAll(() => const LoginScreen());
                },
                color: AppColors.kred,
                svgIcon: AppImages.logout,
                textStyle: AppTextStyles.kblack14700.copyWith(
                  color: AppColors.kwhite,
                ),
                centerIcon: true,
              )),




              100.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.kwhite16700
        ),
        12.verticalSpace,
        Column(
            children: items,
          ),

      ],
    );
  }

  Widget _buildSettingItem(String title, String icon) {
    return GestureDetector(
      onTap: () => _navigateToScreen(title),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.kwhite4,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: AppColors.ktertiary,
              child: SvgPicture.asset(
                icon,
                width: 24.w,
                height: 24.w,
              )
            ),
            14.horizontalSpace,
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.kblack14500.copyWith(
                  color: AppColors.kwhite,
                )
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.kwhite,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(String title) {
    Widget? screen;
    
    switch (title) {
      case 'Personal Information':
        screen = const ProfileScreen();
        break;
      case 'Favourite':
        screen = const FavouriteScreen(showBackButton: true);
        break;
      case 'Notifications':
        screen = const NotificationsSettingsScreen();
        break;
      case 'Help/FAQs':
        screen = const HelpFaq();
        break;
      case 'Terms & Conditions':
        screen = const TermsAndCondition();
        break;
      case 'Privacy Policy':
        screen = const PrivacyPolicy();
        break;
      case 'About':
        screen = const AboutApp();
        break;
      case 'Security':
        screen = const SecurityScreen();
        break;
      default:
        return;
    }
    
    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }
}