import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../auth/login_screen.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/images.dart';
import '../../core/constants/fonts.dart';
import '../../widgets/custom_button.dart';


class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;


  final List<OnboardingModel> _onboardingData = [
    OnboardingModel(
      image: AppImages.onboarding1,
      title: "AI-Powered Market Forecasts",
      description: "Real-time predictions for crypto, stocks, and market trends",
      showOverlay: false,
    ),
    OnboardingModel(
      image: AppImages.onboarding2,
      title: "Track Accuracy & Make Better Decisions",
      description: "Analyze trends, track accuracy, invest smarter",
      showOverlay: true,
    ),
  ];


  @override


  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarColor: AppColors.ksecondary,
          statusBarColor: Colors.transparent, // Transparent status bar
          statusBarBrightness: Brightness.dark, // iOS: white icons
          statusBarIconBrightness: Brightness.light, // Android: white icons
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
        child: Stack(
          children: [
            // Main PageView content (full screen)
            PageView.builder(
              physics: NeverScrollableScrollPhysics(),

              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },

              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return _buildOnboardingPage(_onboardingData[index]);
              },
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.93.w),
                decoration: BoxDecoration(
                  color: AppColors.ksecondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28.r),
                    topRight: Radius.circular(28.r),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Title and description text
                    Text(
                      _onboardingData[_currentPage].title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.kblack24700.copyWith(
                        color: AppColors.kwhite
                      )
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      _onboardingData[_currentPage].description,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.ksblack16600.copyWith(
                        color: AppColors.kgrey2
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomButton(
                      text: _currentPage == _onboardingData.length - 1 ? "Get Started" : "Next",
                      onPressed: () {
                        if (_currentPage == _onboardingData.length - 1) {
                          _skipOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      color: AppColors.kprimary,
                      textStyle: AppTextStyles.kblack18500.copyWith(
                        color: AppColors.kwhite
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // Skip button - positioned LAST so it appears on top
            Positioned(
              top: 16.h,
              right: 16.w,
              child: GestureDetector(
                onTap: () {
                  print('Skip tapped');
                  _skipOnboarding();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.kwhite,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "Skip",
                    style: AppTextStyles.ksblack12600.copyWith(
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingModel data) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Padding(padding: EdgeInsets.only(
            left: 25.w,
            right: 25.w,
            //top: 60.h,
          ),
          child:
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(data.image),
              ),
            ),
          ),
    ),


          // // Forecast Information overlay for first screen
          // if (!data.showOverlay)
          //   Positioned(
          //     bottom: 350.h,
          //     left: 35.w,
          //     child: Container(
          //       padding: EdgeInsets.symmetric(
          //         horizontal: 12.w,
          //         vertical: 8.h,
          //       ),
          //       decoration: BoxDecoration(
          //         color: Colors.black.withOpacity(0.7),
          //         borderRadius: BorderRadius.circular(8.r),
          //       ),
          //       child: Text(
          //         "Forecast Information",
          //         style: TextStyle(
          //           color: AppColors.kwhite,
          //           fontSize: 14.sp,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }


  void _skipOnboarding() {
    // Navigate to BottomNavBar (main app)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}

class OnboardingModel {
  final String image;
  final String title;
  final String description;
  final bool showOverlay;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.description,
    required this.showOverlay,
  });
}