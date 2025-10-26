import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/images.dart';

class TermsAndCondition extends StatefulWidget {
  const TermsAndCondition({super.key});

  @override
  State<TermsAndCondition> createState() => _TermsAndConditionState();
}

class _TermsAndConditionState extends State<TermsAndCondition> {
  final TextEditingController _searchController = TextEditingController();

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
                  Text('Terms & Conditions', style: AppTextStyles.ktwhite16500),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Updated: January 2025',
                      style: AppTextStyles.kblack12500.copyWith(
                        color: AppColors.kwhite2,
                      ),
                    ),
                    24.verticalSpace,

                    _buildSection(
                      '1. Acceptance of Terms',
                      'By accessing and using ForcastIQ ("the App"), you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to these Terms & Conditions, please do not use the App.',
                    ),

                    _buildSection(
                      '2. Description of Service',
                      'ForcastIQ provides AI-powered market forecasts and predictions for cryptocurrencies, stocks, and macroeconomic indicators. Our service includes:\n\n• Real-time market data and price updates\n• AI-generated forecast predictions\n• Historical trend analysis and accuracy tracking\n• Notifications and alerts\n• Favorites management\n\nThe App is provided for informational purposes only.',
                    ),

                    _buildSection(
                      '3. Investment Disclaimer',
                      'IMPORTANT: ForcastIQ does not provide investment advice. All forecasts, predictions, and market data are for informational purposes only and should not be considered as financial, investment, or trading advice.\n\n• Past performance does not guarantee future results\n• All investments carry risk, including loss of capital\n• You should conduct your own research before making investment decisions\n• Consult with a licensed financial advisor before making investment decisions\n• ForcastIQ is not liable for any investment losses',
                    ),

                    _buildSection(
                      '4. Accuracy of Information',
                      'While we strive to provide accurate and up-to-date information, ForcastIQ does not guarantee the accuracy, completeness, or reliability of any forecasts or market data. Market conditions can change rapidly, and our predictions may not reflect real-time market movements.',
                    ),

                    _buildSection(
                      '5. User Accounts',
                      'To use ForcastIQ, you may create an account using:\n\n• Email and password\n• Google Sign-In\n• Apple Sign-In\n\nYou are responsible for:\n• Maintaining the confidentiality of your account credentials\n• All activities that occur under your account\n• Notifying us immediately of any unauthorized access\n• Providing accurate and complete registration information',
                    ),

                    _buildSection(
                      '6. Acceptable Use',
                      'You agree NOT to:\n\n• Use the App for illegal purposes\n• Attempt to gain unauthorized access to our systems\n• Interfere with or disrupt the App\'s functionality\n• Reverse engineer or decompile the App\n• Use automated tools to access the App without permission\n• Distribute malware or harmful code\n• Violate any applicable laws or regulations',
                    ),

                    _buildSection(
                      '7. Intellectual Property',
                      'All content, features, and functionality of ForcastIQ, including but not limited to text, graphics, logos, icons, images, AI algorithms, and software, are the exclusive property of ForcastIQ and are protected by international copyright, trademark, and other intellectual property laws.',
                    ),

                    _buildSection(
                      '8. Data Collection and Privacy',
                      'Your use of ForcastIQ is also governed by our Privacy Policy, which describes how we collect, use, and protect your personal information. By using the App, you consent to our data practices as described in the Privacy Policy.',
                    ),

                    _buildSection(
                      '9. Third-Party Services',
                      'ForcastIQ may integrate with third-party services including:\n\n• Supabase (authentication and data storage)\n• Google Sign-In\n• Apple Sign-In\n• Market data providers\n\nWe are not responsible for the privacy practices or content of these third-party services.',
                    ),

                    _buildSection(
                      '10. Limitation of Liability',
                      'TO THE MAXIMUM EXTENT PERMITTED BY LAW, ForcastIQ SHALL NOT BE LIABLE FOR:\n\n• Any investment losses or financial damages\n• Inaccurate forecasts or predictions\n• Delays or interruptions in service\n• Loss of data or information\n• Any indirect, incidental, special, or consequential damages\n• Any damages arising from your use of the App',
                    ),

                    _buildSection(
                      '11. Service Modifications',
                      'ForcastIQ reserves the right to:\n\n• Modify or discontinue any feature at any time\n• Update the App without prior notice\n• Change pricing or subscription plans\n• Suspend or terminate accounts for violations\n\nWe will make reasonable efforts to notify users of significant changes.',
                    ),

                    _buildSection(
                      '12. Termination',
                      'We may terminate or suspend your account immediately, without prior notice, for:\n\n• Violation of these Terms & Conditions\n• Fraudulent or illegal activity\n• Abuse of the service\n• Non-payment (if applicable)\n\nYou may delete your account at any time through Settings > Delete Account.',
                    ),

                    _buildSection(
                      '13. Updates to Terms',
                      'We may update these Terms & Conditions from time to time. We will notify users of material changes through:\n\n• In-app notifications\n• Email notifications\n• Update to "Last Updated" date\n\nContinued use of the App after changes constitutes acceptance of the new terms.',
                    ),

                    _buildSection(
                      '14. Governing Law',
                      'These Terms & Conditions shall be governed by and construed in accordance with applicable laws, without regard to conflict of law provisions.',
                    ),

                    _buildSection(
                      '15. Contact Information',
                      'If you have questions about these Terms & Conditions, please contact us through the Settings screen or via email.',
                    ),

                    _buildSection(
                      '16. Severability',
                      'If any provision of these Terms & Conditions is found to be unenforceable or invalid, that provision will be limited or eliminated to the minimum extent necessary, and the remaining provisions will remain in full force and effect.',
                    ),

                    _buildSection(
                      '17. Entire Agreement',
                      'These Terms & Conditions, together with our Privacy Policy, constitute the entire agreement between you and ForcastIQ regarding the use of the App.',
                    ),

                    50.verticalSpace,

                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.ktertiary,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.kprimary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.kprimary,
                                size: 20.r,
                              ),
                              8.horizontalSpace,
                              Text(
                                'Important Notice',
                                style: AppTextStyles.kwhite16700.copyWith(
                                  color: AppColors.kprimary,
                                ),
                              ),
                            ],
                          ),
                          12.verticalSpace,
                          Text(
                            'By using ForcastIQ, you acknowledge that you have read, understood, and agree to be bound by these Terms & Conditions.',
                            style: AppTextStyles.kblack14500.copyWith(
                              color: AppColors.kwhite2,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.kwhite16700.copyWith(
              color: AppColors.kwhite,
            ),
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
}