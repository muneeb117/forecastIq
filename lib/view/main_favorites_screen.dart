import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:get/get.dart';
import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';
import '../widgets/Item_Widget.dart';
import 'coin_detail_screen.dart';

class MainFavouriteScreen extends StatefulWidget {
  const MainFavouriteScreen({super.key});

  @override
  State<MainFavouriteScreen> createState() => _MainFavouriteScreenState();
}

class _MainFavouriteScreenState extends State<MainFavouriteScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _tabs = ['All', 'Stocks', 'Crypto', 'Macro'];

  // All items data for filtering
  final List<Map<String, dynamic>> _allStocksItems = [
    {
      'image': null,
      'symbol': 'AAPL',
      'name': 'Apple Inc.',
      'percentage': '86%',
      'isUp': false,
      'price': '\$150.2k-\$155.4k',
    },
    {
      'image': null,
      'symbol': 'MSFT',
      'name': 'Microsoft',
      'percentage': '92%',
      'isUp': true,
      'price': '\$280.2k-\$285.4k',
    },
    {
      'image': null,
      'symbol': 'GOOGL',
      'name': 'Alphabet',
      'percentage': '78%',
      'isUp': true,
      'price': '\$120.2k-\$125.4k',
    },
    {
      'image': null,
      'symbol': 'TSLA',
      'name': 'Tesla',
      'percentage': '65%',
      'isUp': false,
      'price': '\$200.2k-\$205.4k',
    },
  ];

  final List<Map<String, dynamic>> _allCryptoItems = [
    {
      'image': AppImages.btc,
      'symbol': 'BTC',
      'name': 'Bitcoin',
      'percentage': '86%',
      'isUp': true,
      'price': '\$28.2k-\$29.4k',
    },
    {
      'image': AppImages.eth,
      'symbol': 'ETH',
      'name': 'Ethereum',
      'percentage': '92%',
      'isUp': true,
      'price': '\$1.8k-\$1.9k',
    },
    {
      'image': null,
      'symbol': 'ADA',
      'name': 'Cardano',
      'percentage': '78%',
      'isUp': false,
      'price': '\$0.45-\$0.50',
    },
    {
      'image': null,
      'symbol': 'DOT',
      'name': 'Polkadot',
      'percentage': '65%',
      'isUp': true,
      'price': '\$6.2k-\$6.8k',
    },
  ];

  final List<Map<String, dynamic>> _allMacroItems = [
    {
      'image': null,
      'symbol': 'USD',
      'name': 'US Dollar',
      'percentage': '86%',
      'isUp': false,
      'price': '1.05-1.08',
    },
    {
      'image': null,
      'symbol': 'EUR',
      'name': 'Euro',
      'percentage': '92%',
      'isUp': true,
      'price': '0.92-0.95',
    },
    {
      'image': null,
      'symbol': 'GBP',
      'name': 'British Pound',
      'percentage': '78%',
      'isUp': true,
      'price': '0.78-0.82',
    },
    {
      'image': null,
      'symbol': 'JPY',
      'name': 'Japanese Yen',
      'percentage': '65%',
      'isUp': false,
      'price': '148-152',
    },
  ];


  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterItems(List<Map<String, dynamic>> items) {
    if (_searchQuery.isEmpty) return items;

    return items.where((item) {
      return item['symbol'].toLowerCase().contains(_searchQuery) ||
          item['name'].toLowerCase().contains(_searchQuery);
    }).toList();
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
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome!', style: AppTextStyles.kswhite12500),
                      Text(
                        'Favourites',
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

              Container(
                height: 54.h,
                decoration: BoxDecoration(
                  color: AppColors.ktertiary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: TextField(
                  controller: _searchController,
                  style: AppTextStyles.kblack14500.copyWith(
                    color: AppColors.kwhite,
                  ),
                  textAlignVertical:
                      TextAlignVertical.center, // Center text vertically
                  decoration: InputDecoration(
                    hintText: 'Search ...',
                    hintStyle: AppTextStyles.kblack14500.copyWith(
                      color: AppColors.kwhite2,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                        left: 20.w,
                        right: 12.w,
                      ), // Adjust icon padding
                      child: SvgPicture.asset(
                        AppImages.search,
                        width: 18.w,
                        height: 18.h,
                        color:
                            AppColors.kwhite, // Ensure icon color matches text
                        fit: BoxFit.contain, // Ensure proper scaling
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 18.w,
                      minHeight: 18.h,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16.h, // Adjust vertical padding for centering
                    ),
                  ),
                ),
              ),
              18.verticalSpace,

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
              23.verticalSpace,

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
      default:
        return _buildAllContent();
    }
  }

  Widget _buildAllContent() {
    List<Map<String, dynamic>> allItems = [
      {
        'image': AppImages.rev,
        'symbol': 'REV',
        'name': 'Revain',
        'percentage': '86%',
        'isUp': false,
        'price': '\$28.2k-\$29.4k',
      },
      {
        'image': AppImages.eth,
        'symbol': 'ETH',
        'name': 'Ethereum',
        'percentage': '86%',
        'isUp': true,
        'price': '\$1.8k-\$1.9k',
      },
      {
        'image': AppImages.btc,
        'symbol': 'BTC',
        'name': 'Bitcoin',
        'percentage': '86%',
        'isUp': true,
        'price': '\$28.2k-\$29.4k',
      },
    ];

    List<Map<String, dynamic>> filteredItems = _filterItems(allItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...filteredItems
            .map(
              (item) => Column(
                children: [
                  buildTrendingItem(
                    item['image'],
                    item['symbol'],
                    item['name'],
                    item['percentage'],
                    item['isUp'],
                    item['price'],
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildStocksContent() {
    List<Map<String, dynamic>> filteredItems = _filterItems(_allStocksItems);

    return Column(
      children: filteredItems
          .map(
            (item) => Column(
              children: [
                buildTrendingItem(
                  item['image'],
                  item['symbol'],
                  item['name'],
                  item['percentage'],
                  item['isUp'],
                  item['price'],
                ),
                SizedBox(height: 12.h),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildCryptoContent() {
    List<Map<String, dynamic>> filteredItems = _filterItems(_allCryptoItems);

    return Column(
      children: filteredItems
          .map(
            (item) => Column(
              children: [
                buildTrendingItem(
                  item['image'],
                  item['symbol'],
                  item['name'],
                  item['percentage'],
                  item['isUp'],
                  item['price'],
                ),
                SizedBox(height: 12.h),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildMacroContent() {
    List<Map<String, dynamic>> filteredItems = _filterItems(_allMacroItems);

    return Column(
      children: filteredItems
          .map(
            (item) => Column(
              children: [
                buildTrendingItem(
                  item['image'],
                  item['symbol'],
                  item['name'],
                  item['percentage'],
                  item['isUp'],
                  item['price'],
                ),
                SizedBox(height: 12.h),
              ],
            ),
          )
          .toList(),
    );
  }



}
