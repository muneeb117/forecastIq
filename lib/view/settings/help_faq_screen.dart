import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';

class HelpFaq extends StatefulWidget {
  const HelpFaq({super.key});

  @override
  State<HelpFaq> createState() => _HelpFaqState();
}

class _HelpFaqState extends State<HelpFaq> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<FAQSection> _sections = [
    FAQSection(
      title: "Getting Started",
      faqs: [
        FAQ(
          question: "What is ForcastIQ?",
          answer: "ForcastIQ is an AI-powered trading forecast application that provides real-time market predictions for cryptocurrencies, stocks, and macroeconomic indicators. Our advanced algorithms analyze market trends to help you make informed investment decisions.",
        ),
        FAQ(
          question: "How do I create an account?",
          answer: "You can create an account by signing up with your email address, or using Google Sign-In or Apple Sign-In. Simply tap 'Sign Up' on the login screen and follow the instructions.",
        ),
        FAQ(
          question: "Is ForcastIQ free to use?",
          answer: "ForcastIQ offers real-time market data and AI-powered forecasts. You can access historical trends, accuracy metrics, and receive notifications for your favorite assets.",
        ),
      ],
    ),
    FAQSection(
      title: "Forecasts & Predictions",
      faqs: [
        FAQ(
          question: "How accurate are the predictions?",
          answer: "Our AI models analyze vast amounts of market data to generate predictions. You can view the accuracy history for each asset in the Historical Trends section, which shows hit rates and error percentages over time.",
        ),
        FAQ(
          question: "What does the confidence score mean?",
          answer: "The confidence score (0-100%) indicates how confident our AI model is about a particular forecast. Higher confidence scores suggest stronger conviction in the prediction.",
        ),
        FAQ(
          question: "What do UP, DOWN, and HOLD mean?",
          answer: "These are forecast directions: UP means we predict the price will rise, DOWN means we expect it to fall, and HOLD suggests the price will remain relatively stable.",
        ),
      ],
    ),
    FAQSection(
      title: "Assets & Markets",
      faqs: [
        FAQ(
          question: "Which cryptocurrencies are supported?",
          answer: "We support 10 major cryptocurrencies: Bitcoin (BTC), Ethereum (ETH), Tether (USDT), Ripple (XRP), Binance Coin (BNB), Solana (SOL), USD Coin (USDC), Dogecoin (DOGE), Cardano (ADA), and TRON (TRX).",
        ),
        FAQ(
          question: "Which stocks are available?",
          answer: "We track 10 major stocks: NVIDIA (NVDA), Microsoft (MSFT), Apple (AAPL), Google (GOOGL), Amazon (AMZN), Meta (META), Broadcom (AVGO), Tesla (TSLA), Berkshire Hathaway (BRK-B), and JPMorgan Chase (JPM).",
        ),
        FAQ(
          question: "How do I add assets to my favorites?",
          answer: "Tap the star icon next to any asset to add it to your favorites. You can view all your favorite assets in the Favorites tab on the home screen.",
        ),
      ],
    ),
    FAQSection(
      title: "Historical Trends",
      faqs: [
        FAQ(
          question: "What is the Historical Trends section?",
          answer: "The Historical Trends section shows you how accurate our predictions have been over time. You can view forecast vs. actual comparisons, hit rates, and error percentages for different timeframes.",
        ),
        FAQ(
          question: "How do I export trend data?",
          answer: "In the Historical Trends screen, tap the 'Export CSV' button at the bottom to download the trend data for the selected asset and timeframe.",
        ),
        FAQ(
          question: "What timeframes are available?",
          answer: "You can view forecasts and trends for multiple timeframes: 1 Hour (1H), 4 Hours (4H), 1 Day (1D), 7 Days (7D), and 1 Month (1M).",
        ),
      ],
    ),
    FAQSection(
      title: "Account & Settings",
      faqs: [
        FAQ(
          question: "How do I reset my password?",
          answer: "On the login screen, tap 'Forgot Password?' and enter your registered email. You'll receive an OTP to reset your password.",
        ),
        FAQ(
          question: "Can I change my email address?",
          answer: "Yes! Go to Settings > Security > Update Email. Enter your new email and verify it with the OTP sent to both your old and new email addresses.",
        ),
        FAQ(
          question: "How do I enable notifications?",
          answer: "Go to Settings > Notifications to customize your notification preferences. You can set up price alerts and market update reminders.",
        ),
      ],
    ),
    FAQSection(
      title: "Troubleshooting",
      faqs: [
        FAQ(
          question: "Why am I not receiving real-time updates?",
          answer: "Make sure you have a stable internet connection. The app uses WebSocket connections for real-time data. Try closing and reopening the app if updates stop.",
        ),
        FAQ(
          question: "What should I do if the app crashes?",
          answer: "Try force closing the app and reopening it. If the problem persists, clear the app cache or reinstall the app. Make sure you're using the latest version.",
        ),
        FAQ(
          question: "How do I contact support?",
          answer: "For additional support, you can reach out to us through the Settings screen. We're here to help with any questions or issues you may encounter.",
        ),
      ],
    ),
  ];

  List<FAQSection> get _filteredSections {
    if (_searchQuery.isEmpty) return _sections;

    return _sections.map((section) {
      final filteredFaqs = section.faqs.where((faq) {
        final query = _searchQuery.toLowerCase();
        return faq.question.toLowerCase().contains(query) ||
            faq.answer.toLowerCase().contains(query);
      }).toList();

      return FAQSection(title: section.title, faqs: filteredFaqs);
    }).where((section) => section.faqs.isNotEmpty).toList();
  }

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
                  Text('Help/FAQs', style: AppTextStyles.ktwhite16500),
                  SizedBox(width: 24.w),
                ],
              ),
            ),
            22.verticalSpace,

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                height: 54.h,
                decoration: BoxDecoration(
                  color: AppColors.ktertiary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: AppTextStyles.kblack14500.copyWith(
                    color: AppColors.kwhite,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Search FAQs...',
                    hintStyle: AppTextStyles.kblack14500.copyWith(
                      color: AppColors.kwhite2,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 12.w),
                      child: SvgPicture.asset(
                        AppImages.search,
                        width: 18.w,
                        height: 18.h,
                        colorFilter: ColorFilter.mode(
                          AppColors.kwhite,
                          BlendMode.srcIn,
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 18.w,
                      minHeight: 18.h,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                ),
              ),
            ),
            32.verticalSpace,

            // FAQ Sections
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _filteredSections.length,
                separatorBuilder: (context, index) => 32.verticalSpace,
                itemBuilder: (context, index) {
                  final section = _filteredSections[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppImages.question,
                            width: 24.w,
                            height: 24.h,
                          ),
                          12.horizontalSpace,
                          Text(
                            section.title,
                            style: AppTextStyles.kwhite16700,
                          ),
                        ],
                      ),
                      16.verticalSpace,
                      ...section.faqs.asMap().entries.map((entry) {
                        final faqIndex = entry.key;
                        final faq = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: faqIndex < section.faqs.length - 1 ? 16.h : 0,
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              title: Text(
                                faq.question,
                                style: AppTextStyles.kblack14700.copyWith(
                                  color: AppColors.kwhite,
                                ),
                              ),
                              iconColor: AppColors.kwhite,
                              collapsedIconColor: AppColors.kwhite,
                              showTrailingIcon: true,
                              tilePadding: EdgeInsets.zero,
                              textColor: AppColors.kwhite,
                              expandedAlignment: Alignment.centerLeft,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Text(
                                    faq.answer,
                                    style: AppTextStyles.kblack14500.copyWith(
                                      color: AppColors.kwhite2,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            20.verticalSpace,
          ],
        ),
      ),
    );
  }
}

class FAQSection {
  final String title;
  final List<FAQ> faqs;

  FAQSection({required this.title, required this.faqs});
}

class FAQ {
  final String question;
  final String answer;

  FAQ({required this.question, required this.answer});
}