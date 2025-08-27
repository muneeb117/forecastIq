import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:get/get.dart';
import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';
import '../widgets/Item_Widget.dart';
import 'coin_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['All', 'Stocks', 'Crypto', 'Macro', 'Favorites'];


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
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColors.kprimary,
                    child: Image.asset(AppImages.user),
                  ),
                  8.horizontalSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome!', style: AppTextStyles.kswhite12500),
                      Text(
                        'Hi Umar!',
                        style: AppTextStyles.kblack18500.copyWith(
                          color: AppColors.kwhite,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
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
                ],
              ),
              23.verticalSpace,

              // Horizontal Tabs Section
              SizedBox(
                height: 31.h,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedTabIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 4.w),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.kprimary
                              : AppColors.ktertiary,
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                        child: Center(
                          child: Text(
                            _tabs[index],
                            style: AppTextStyles.ktblack13400.copyWith(
                              color: isSelected
                                  ? AppColors.kblack
                                  : AppColors.kwhite,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              8.verticalSpace,

              // Content based on selected tab
              _buildTabContent(),
              100.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // All
        return _buildAllContent();
      case 1: // Stocks
        return _buildStocksContent();
      case 2: // Crypto
        return _buildCryptoContent();
      case 3: // Macro
        return _buildMacroContent();
      case 4: // Favorites
        return _buildFavoritesContent();
      default:
        return _buildAllContent();
    }
  }

  Widget _buildAllContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trending Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trending',
              style: AppTextStyles.kblack16500.copyWith(
                color: AppColors.kwhite,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'see all',
                    style: AppTextStyles.kblack14500.copyWith(
                      color: AppColors.kprimary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.kprimary,
                    ),
                  ),
                  4.horizontalSpace,
                  SvgPicture.asset(AppImages.arrow, width: 18.w, height: 18.h),
                ],
              ),
            ),
          ],
        ),

        8.verticalSpace,

        // Trending Items
        buildTrendingItem(
          AppImages.btc,
          'BTC',
          'Bitcoin',
          '86%',
          true,
          '\$28.2k-\$29.4k',
        ),

        23.verticalSpace,

        // Market Summary Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Market Summary',
              style: AppTextStyles.kblack16500.copyWith(
                color: AppColors.kwhite,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'see all',
                    style: AppTextStyles.kblack14500.copyWith(
                      color: AppColors.kprimary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.kprimary,
                    ),
                  ),
                  4.horizontalSpace,
                  SvgPicture.asset(AppImages.arrow, width: 18.w, height: 18.h),
                ],
              ),
            ),
          ],
        ),

        8.verticalSpace,

        // Market Summary Items
        buildTrendingItem(
          AppImages.rev,
          'REV',
          'Revain',
          '86%',
          false,
          '\$28.2k-\$29.4k',
        ),
        SizedBox(height: 12.h),
        buildTrendingItem(
          AppImages.eth,
          'ETH',
          'Ethereum',
          '86%',
          true,
          '\$28.2k-\$29.4k',
        ),
        SizedBox(height: 12.h),
        buildTrendingItem(
          AppImages.btc,
          'BTC',
          'Bitcoin',
          '86%',
          true,
          '\$28.2k-\$29.4k',
        ),
      ],
    );
  }

  Widget _buildStocksContent() {
    return Column(
      children: [
        buildTrendingItem(
          null,
          'AAPL',
          'Apple Inc.',
          '86%',
          false,
          '\$150.2k-\$155.4k',
        ),
        SizedBox(height: 12.h),
        buildTrendingItem(null, 'MSFT', 'Microsoft', '92%', true, '\$280.2k-\$285.4k'),
        SizedBox(height: 12.h),
        buildTrendingItem(null, 'GOOGL', 'Alphabet', '78%', true, '\$120.2k-\$125.4k'),
        SizedBox(height: 12.h),
        buildTrendingItem(null, 'TSLA', 'Tesla', '65%', false, '\$200.2k-\$205.4k'),
      ],
    );
  }

  Widget _buildCryptoContent() {
    return Column(
      children: [
        buildTrendingItem(AppImages.btc, 'BTC', 'Bitcoin', '86%', true, '\$28.2k-\$29.4k'),
        SizedBox(height: 12.h),
        buildTrendingItem(AppImages.eth, 'ETH', 'Ethereum', '92%', true, '\$1.8k-\$1.9k'),
        SizedBox(height: 12.h),
        buildTrendingItem(null, 'ADA', 'Cardano', '78%', false, '\$0.45-\$0.50'),
        SizedBox(height: 12.h),
        buildTrendingItem(null, 'DOT', 'Polkadot', '65%', true, '\$6.2k-\$6.8k'),
      ],
    );
  }

  Widget _buildMacroContent() {
    return Column(
      children: [
        buildTrendingItem(null, 'USD', 'US Dollar', '86%', false, '1.05-1.08'),
        SizedBox(height: 12.h),
        buildTrendingItem(null, 'EUR', 'Euro', '92%', true, '0.92-0.95'),
        SizedBox(height: 12.h),
        buildTrendingItem(null, 'GBP', 'British Pound', '78%', true, '0.78-0.82'),
        SizedBox(height: 12.h),
        buildTrendingItem(null, 'JPY', 'Japanese Yen', '65%', false, '148-152'),
      ],
    );
  }

  Widget _buildFavoritesContent() {
    return Column(
      children: [
        buildTrendingItem(AppImages.btc, 'BTC', 'Bitcoin', '86%', true, '\$28.2k-\$29.4k'),
        SizedBox(height: 12.h),
        buildTrendingItem(
          null,
          'AAPL',
          'Apple Inc.',
          '92%',
          true,
          '\$150.2k-\$155.4k',
        ),
        SizedBox(height: 12.h),
        buildTrendingItem(null, 'EUR', 'Euro', '78%', false, '0.92-0.95'),
        SizedBox(height: 12.h),
        buildTrendingItem(AppImages.eth, 'ETH', 'Ethereum', '85%', true, '\$1.8k-\$1.9k'),
      ],
    );
  }

}
