import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';

class AboutApp extends StatefulWidget {
  const AboutApp({super.key});

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
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
                  Text('About App', style: AppTextStyles.ktwhite16500),
                  SizedBox(width: 24.w),
                ],
              ),
            ),
            22.verticalSpace,

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    32.verticalSpace,

                    // App Logo/Icon
                    Container(
                      width: 100.w,
                      height: 100.h,
                      decoration: BoxDecoration(
                        color: AppColors.kprimary,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.trending_up,
                          size: 60.r,
                          color: AppColors.kwhite,
                        ),
                      ),
                    ),
                    24.verticalSpace,

                    // App Name
                    Text(
                      'ForcastIQ',
                      style: AppTextStyles.kwhite32700.copyWith(
                        color: AppColors.kwhite,
                        fontSize: 28.sp,
                      ),
                    ),
                    8.verticalSpace,

                    // Tagline
                    Text(
                      'Smarter predictions. Better decisions.',
                      style: AppTextStyles.kblack14500.copyWith(
                        color: AppColors.kwhite2,
                        fontSize: 14.sp,
                      ),
                    ),
                    8.verticalSpace,

                    // Version
                    Text(
                      'Version 1.0.0',
                      style: AppTextStyles.kblack12500.copyWith(
                        color: AppColors.kwhite2,
                      ),
                    ),
                    40.verticalSpace,

                    // About Section
                    _buildInfoCard(
                      icon: Icons.info_outline,
                      title: 'About ForcastIQ',
                      content: 'ForcastIQ is an advanced AI-powered trading forecast application that provides real-time market predictions for cryptocurrencies, stocks, and macroeconomic indicators. Our cutting-edge algorithms analyze vast amounts of market data to deliver accurate forecasts and help you make informed investment decisions.',
                    ),

                    16.verticalSpace,

                    // Mission Section
                    _buildInfoCard(
                      icon: Icons.flag_outlined,
                      title: 'Our Mission',
                      content: 'To democratize access to professional-grade market intelligence and empower everyone to make smarter investment decisions through AI-driven insights.',
                    ),

                    16.verticalSpace,

                    // Features Section
                    _buildInfoCard(
                      icon: Icons.stars_outlined,
                      title: 'Key Features',
                      content: '• AI-Powered Forecasts\n• Real-Time Market Data\n• Historical Trend Analysis\n• Multi-Asset Support (Crypto, Stocks, Macro)\n• Accuracy Tracking\n• Customizable Notifications\n• Favorites Management\n• Data Export (CSV)',
                    ),

                    16.verticalSpace,

                    // Supported Assets
                    _buildInfoCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Supported Assets',
                      content: '10 Cryptocurrencies: BTC, ETH, USDT, XRP, BNB, SOL, USDC, DOGE, ADA, TRX\n\n10 Stocks: NVDA, MSFT, AAPL, GOOGL, AMZN, META, AVGO, TSLA, BRK-B, JPM\n\n5 Macro Indicators: GDP, CPI, UNEMPLOYMENT, FED_RATE, CONSUMER_CONFIDENCE',
                    ),

                    16.verticalSpace,

                    // Technology Stack
                    _buildInfoCard(
                      icon: Icons.code_outlined,
                      title: 'Technology',
                      content: 'Built with Flutter for seamless cross-platform performance. Powered by advanced machine learning models and real-time WebSocket connections for instant market updates.',
                    ),

                    16.verticalSpace,

                    // Disclaimer
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.ktertiary,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_outlined,
                                color: Colors.orange,
                                size: 20.r,
                              ),
                              8.horizontalSpace,
                              Text(
                                'Important Disclaimer',
                                style: AppTextStyles.kwhite16700.copyWith(
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          12.verticalSpace,
                          Text(
                            'ForcastIQ provides market forecasts for informational purposes only. This is NOT financial advice. All investments carry risk. Past performance does not guarantee future results. Always conduct your own research and consult with a licensed financial advisor before making investment decisions.',
                            style: AppTextStyles.kblack14500.copyWith(
                              color: AppColors.kwhite2,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    32.verticalSpace,

                    // Contact Section
                    // Text(
                    //   'Contact & Support',
                    //   style: AppTextStyles.kwhite16700.copyWith(
                    //     color: AppColors.kwhite,
                    //   ),
                    // ),
                    // 16.verticalSpace,

                    // _buildContactButton(
                    //   icon: Icons.email_outlined,
                    //   label: 'Email Support',
                    //   onTap: () {
                    //     // Add email support functionality
                    //   },
                    // ),
                    //
                    // 12.verticalSpace,
                    //
                    // _buildContactButton(
                    //   icon: Icons.help_outline,
                    //   label: 'Help & FAQs',
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //   },
                    // ),



                    16.verticalSpace,

                    // Copyright
                    Text(
                      '© 2025 ForcastIQ. All rights reserved.',
                      style: AppTextStyles.kblack12500.copyWith(
                        color: AppColors.kwhite2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    50.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.ksecondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.kprimary,
                size: 20.r,
              ),
              8.horizontalSpace,
              Text(
                title,
                style: AppTextStyles.kwhite16700.copyWith(
                  color: AppColors.kwhite,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Text(
            content,
            style: AppTextStyles.kblack14500.copyWith(
              color: AppColors.kwhite2,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.ksecondary,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.kwhite.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.kprimary,
              size: 20.r,
            ),
            12.horizontalSpace,
            Text(
              label,
              style: AppTextStyles.kblack14500.copyWith(
                color: AppColors.kwhite,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.kwhite2,
              size: 16.r,
            ),
          ],
        ),
      ),
    );
  }
}