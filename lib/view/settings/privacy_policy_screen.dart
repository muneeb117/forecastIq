import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
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
                  Text('Privacy Policy', style: AppTextStyles.ktwhite16500),
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

                    Text(
                      'At ForcastIQ, we take your privacy seriously. This Privacy Policy explains how we collect, use, share, and protect your personal information when you use our app.',
                      style: AppTextStyles.kblack14500.copyWith(
                        color: AppColors.kwhite2,
                        height: 1.6,
                      ),
                    ),
                    32.verticalSpace,

                    _buildSection(
                      '1. Information We Collect',
                      'We collect several types of information to provide and improve our services:\n\nAccount Information:\n• Email address\n• Name (if provided)\n• Profile picture (if uploaded)\n• Password (encrypted)\n• OAuth credentials (Google/Apple Sign-In)\n\nUsage Data:\n• Assets you view and favorite\n• Forecast preferences and timeframes\n• Notification preferences\n• App interactions and feature usage\n\nDevice Information:\n• Device type and model\n• Operating system version\n• App version\n• IP address\n• Device identifiers',
                    ),

                    _buildSection(
                      '2. How We Use Your Information',
                      'We use the information we collect to:\n\n• Provide and maintain ForcastIQ services\n• Authenticate your identity and manage your account\n• Deliver real-time market data and forecasts\n• Send notifications and alerts you\'ve requested\n• Personalize your experience (favorites, preferences)\n• Analyze app usage to improve features\n• Detect and prevent fraud or abuse\n• Comply with legal obligations\n• Communicate important updates and changes',
                    ),

                    _buildSection(
                      '3. Data Storage and Security',
                      'We implement industry-standard security measures to protect your data:\n\n• All data is transmitted using SSL/TLS encryption\n• Passwords are securely hashed and never stored in plain text\n• We use Supabase for secure authentication and data storage\n• Regular security audits and updates\n• Access controls and authentication protocols\n\nHowever, no method of transmission over the internet is 100% secure. While we strive to protect your personal information, we cannot guarantee absolute security.',
                    ),

                    _buildSection(
                      '4. Third-Party Services',
                      'ForcastIQ integrates with the following third-party services:\n\nSupabase:\n• Authentication and user management\n• Secure data storage\n• Privacy Policy: https://supabase.com/privacy\n\nGoogle Sign-In:\n• OAuth authentication\n• Privacy Policy: https://policies.google.com/privacy\n\nApple Sign-In:\n• OAuth authentication\n• Privacy Policy: https://www.apple.com/legal/privacy\n\nMarket Data Providers:\n• Real-time cryptocurrency and stock data\n• Aggregate market information\n\nThese services have their own privacy policies and data collection practices. We encourage you to review them.',
                    ),

                    _buildSection(
                      '5. Data Sharing and Disclosure',
                      'We do NOT sell your personal information. We may share your data only in these circumstances:\n\n• With your explicit consent\n• To comply with legal obligations or court orders\n• To protect our rights, property, or safety\n• In connection with a merger, acquisition, or sale of assets\n• With service providers who assist in app operations (under strict confidentiality)\n\nWe do not share your personal information with advertisers or third parties for marketing purposes.',
                    ),

                    _buildSection(
                      '6. Your Privacy Rights',
                      'You have the following rights regarding your personal data:\n\nAccess: Request a copy of your personal data\n\nCorrection: Update inaccurate or incomplete information through Settings > Profile\n\nDeletion: Delete your account and personal data through Settings > Delete Account\n\nData Portability: Request your data in a portable format\n\nWithdrawal of Consent: Opt out of notifications or data collection features\n\nTo exercise these rights, contact us through the Settings screen or via email.',
                    ),

                    _buildSection(
                      '7. Cookies and Tracking',
                      'ForcastIQ uses minimal tracking technologies:\n\n• Local storage for app preferences and favorites\n• Session tokens for authentication\n• Anonymous analytics for app improvement\n\nWe do NOT use third-party advertising cookies or tracking pixels.',
                    ),

                    _buildSection(
                      '8. Children\'s Privacy',
                      'ForcastIQ is not intended for users under the age of 18. We do not knowingly collect personal information from children. If you believe a child has provided us with personal information, please contact us immediately, and we will delete such information.',
                    ),

                    _buildSection(
                      '9. Data Retention',
                      'We retain your personal information for as long as your account is active or as needed to provide services. When you delete your account:\n\n• Personal information is permanently deleted within 30 days\n• Some data may be retained for legal or security purposes\n• Aggregated, anonymized data may be retained for analytics',
                    ),

                    _buildSection(
                      '10. International Data Transfers',
                      'Your information may be transferred to and processed in countries other than your own. We ensure that appropriate safeguards are in place to protect your data in compliance with applicable data protection laws.',
                    ),

                    _buildSection(
                      '11. California Privacy Rights',
                      'If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA):\n\n• Right to know what personal information is collected\n• Right to know if personal information is sold or disclosed\n• Right to say no to the sale of personal information\n• Right to request deletion of personal information\n• Right to non-discrimination for exercising your rights\n\nWe do NOT sell your personal information.',
                    ),

                    _buildSection(
                      '12. GDPR Rights (European Users)',
                      'If you are in the European Economic Area (EEA), you have rights under the General Data Protection Regulation (GDPR):\n\n• Right to access your personal data\n• Right to rectification of inaccurate data\n• Right to erasure ("right to be forgotten")\n• Right to restrict processing\n• Right to data portability\n• Right to object to processing\n• Right to withdraw consent\n\nTo exercise these rights, contact us through the app.',
                    ),

                    _buildSection(
                      '13. Changes to Privacy Policy',
                      'We may update this Privacy Policy from time to time. We will notify you of significant changes through:\n\n• In-app notifications\n• Email notifications\n• Update to "Last Updated" date\n\nContinued use of ForcastIQ after changes constitutes acceptance of the updated policy.',
                    ),

                    _buildSection(
                      '14. Contact Information',
                      'If you have questions, concerns, or requests regarding this Privacy Policy or your personal data, please contact us through:\n\n• Settings screen in the app\n• Email support (available in Settings)\n\nWe will respond to your inquiries within a reasonable timeframe.',
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
                                Icons.security,
                                color: AppColors.kprimary,
                                size: 20.r,
                              ),
                              8.horizontalSpace,
                              Text(
                                'Your Privacy Matters',
                                style: AppTextStyles.kwhite16700.copyWith(
                                  color: AppColors.kprimary,
                                ),
                              ),
                            ],
                          ),
                          12.verticalSpace,
                          Text(
                            'We are committed to protecting your privacy and ensuring the security of your personal information. If you have any concerns, please don\'t hesitate to contact us.',
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