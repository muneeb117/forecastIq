import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../widgets/item_widget.dart';
import '../../services/favorites_service.dart';
import '../notifications/notifications_list_screen.dart';

class FavouriteScreen extends StatefulWidget {
  final bool showBackButton;
  const FavouriteScreen({super.key, this.showBackButton = false});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FavoritesService _favoritesService = FavoritesService.instance;
  List<FavoriteItem> _favorites = [];

  final List<String> _tabs = ['All', 'Stocks', 'Crypto', 'Macro'];

  @override
  void initState() {
    super.initState();
    _initializeFavorites();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _initializeFavorites() async {
    await _favoritesService.init();
    _favoritesService.addListener(_onFavoritesChanged);
    setState(() {
      _favorites = _favoritesService.favorites;
    });
  }

  void _onFavoritesChanged(List<FavoriteItem> favorites) {
    if (mounted) {
      setState(() {
        _favorites = favorites;
      });
    }
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_onFavoritesChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<FavoriteItem> _filterFavorites(List<FavoriteItem> items) {
    if (_searchQuery.isEmpty) return items;

    return items.where((item) {
      return item.symbol.toLowerCase().contains(_searchQuery) ||
          item.name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Map<String, String> _getItemImage(String symbol) {
    // Map symbols to their corresponding images
    switch (symbol.toUpperCase()) {
      // All Crypto Coins with PNG Images
      case 'BTC':
        return {'image': AppImages.btc, 'percentage': '86%', 'price': '\$28.2k-\$29.4k'};
      case 'ETH':
        return {'image': AppImages.eth, 'percentage': '92%', 'price': '\$1.8k-\$1.9k'};
      case 'USDT':
        return {'image': AppImages.usdt, 'percentage': '95%', 'price': '\$0.998-\$1.002'};
      case 'XRP':
        return {'image': AppImages.xrp, 'percentage': '78%', 'price': '\$0.45-\$0.52'};
      case 'BNB':
        return {'image': AppImages.bnb, 'percentage': '84%', 'price': '\$220-\$240'};
      case 'SOL':
        return {'image': AppImages.sol, 'percentage': '81%', 'price': '\$18-\$22'};
      case 'USDC':
        return {'image': AppImages.usdc, 'percentage': '96%', 'price': '\$0.999-\$1.001'};
      case 'DOGE':
        return {'image': AppImages.doge, 'percentage': '72%', 'price': '\$0.06-\$0.08'};
      case 'ADA':
        return {'image': AppImages.ada, 'percentage': '75%', 'price': '\$0.25-\$0.32'};
      case 'TRX':
        return {'image': AppImages.trx, 'percentage': '73%', 'price': '\$0.09-\$0.12'};
      case 'REV':
        return {'image': AppImages.rev, 'percentage': '86%', 'price': '\$28.2k-\$29.4k'};

      // Stock Assets
      case 'AAPL':
        return {'image': '', 'percentage': '86%', 'price': '\$150.2k-\$155.4k'};
      case 'MSFT':
        return {'image': '', 'percentage': '92%', 'price': '\$280.2k-\$285.4k'};
      case 'GOOGL':
        return {'image': '', 'percentage': '78%', 'price': '\$120.2k-\$125.4k'};
      case 'TSLA':
        return {'image': '', 'percentage': '65%', 'price': '\$200.2k-\$205.4k'};
      case 'NVDA':
        return {'image': '', 'percentage': '88%', 'price': '\$400-\$450'};
      case 'AMZN':
        return {'image': '', 'percentage': '82%', 'price': '\$120-\$135'};
      case 'META':
        return {'image': '', 'percentage': '79%', 'price': '\$280-\$310'};
      case 'AVGO':
        return {'image': '', 'percentage': '85%', 'price': '\$800-\$850'};
      case 'BRK-B':
        return {'image': '', 'percentage': '90%', 'price': '\$350-\$370'};
      case 'JPM':
        return {'image': '', 'percentage': '87%', 'price': '\$140-\$155'};

      // Macro Assets
      case 'USD':
        return {'image': '', 'percentage': '86%', 'price': '1.05-1.08'};
      case 'EUR':
        return {'image': '', 'percentage': '92%', 'price': '0.92-0.95'};
      case 'GBP':
        return {'image': '', 'percentage': '78%', 'price': '0.78-0.82'};
      case 'JPY':
        return {'image': '', 'percentage': '65%', 'price': '148-152'};
      case 'GDP':
        return {'image': '', 'percentage': '88%', 'price': '2.1%-2.5%'};
      case 'CPI':
        return {'image': '', 'percentage': '92%', 'price': '3.2%-3.8%'};
      case 'UNEMPLOYMENT':
        return {'image': '', 'percentage': '85%', 'price': '3.8%-4.2%'};
      case 'FED_RATE':
        return {'image': '', 'percentage': '91%', 'price': '5.25%-5.75%'};
      case 'CONSUMER_CONFIDENCE':
        return {'image': '', 'percentage': '76%', 'price': '100-110'};

      default:
        return {'image': '', 'percentage': '75%', 'price': 'N/A'};
    }
  }

  bool _getTrendDirection(String symbol) {
    // Simple logic to determine trend - you can make this more sophisticated
    const upTrendSymbols = ['BTC', 'ETH', 'MSFT', 'GOOGL', 'DOT', 'EUR', 'GBP'];
    return upTrendSymbols.contains(symbol.toUpperCase());
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
              if (widget.showBackButton) Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: SvgPicture.asset(
                              AppImages.left,
                              width: 24.w,
                              height: 24.h,
                            )),
                        Text('Favourites', style: AppTextStyles.ktwhite16500),
                        SizedBox()
                      ],
                    ) else Row(
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
                        GestureDetector(
                          onTap: (){
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
    List<FavoriteItem> allFavorites = _filterFavorites(_favorites);

    if (allFavorites.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: 50.h),
            Icon(
              Icons.favorite_border,
              size: 48.w,
              color: AppColors.kwhite.withOpacity(0.4),
            ),
            SizedBox(height: 16.h),
            Text(
              'No favorites yet',
              style: AppTextStyles.ktwhite16400.copyWith(
                color: AppColors.kwhite.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start adding items to your favorites!',
              style: AppTextStyles.ktwhite12500.copyWith(
                color: AppColors.kwhite.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...allFavorites.map(
          (favorite) {
            final itemData = _getItemImage(favorite.symbol);
            return Column(
              children: [
                buildTrendingItem(
                  favorite.image ?? (itemData['image']!.isNotEmpty ? itemData['image'] : null),
                  favorite.symbol,
                  favorite.name,
                  itemData['percentage']!,
                  _getTrendDirection(favorite.symbol),
                  itemData['price']!,
                ),
                SizedBox(height: 12.h),
              ],
            );
          },
        ).toList(),
      ],
    );
  }

  Widget _buildStocksContent() {
    List<FavoriteItem> stockFavorites = _filterFavorites(_favoritesService.stockFavorites);

    if (stockFavorites.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: 50.h),
            Icon(
              Icons.trending_up,
              size: 48.w,
              color: AppColors.kwhite.withOpacity(0.4),
            ),
            SizedBox(height: 16.h),
            Text(
              'No stock favorites yet',
              style: AppTextStyles.ktwhite16400.copyWith(
                color: AppColors.kwhite.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: stockFavorites.map(
        (favorite) {
          final itemData = _getItemImage(favorite.symbol);
          return Column(
            children: [
              buildTrendingItem(
                favorite.image ?? (itemData['image']!.isNotEmpty ? itemData['image'] : null),
                favorite.symbol,
                favorite.name,
                itemData['percentage']!,
                _getTrendDirection(favorite.symbol),
                itemData['price']!,
              ),
              SizedBox(height: 12.h),
            ],
          );
        },
      ).toList(),
    );
  }

  Widget _buildCryptoContent() {
    List<FavoriteItem> cryptoFavorites = _filterFavorites(_favoritesService.cryptoFavorites);

    if (cryptoFavorites.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: 50.h),
            Icon(
              Icons.currency_bitcoin,
              size: 48.w,
              color: AppColors.kwhite.withOpacity(0.4),
            ),
            SizedBox(height: 16.h),
            Text(
              'No crypto favorites yet',
              style: AppTextStyles.ktwhite16400.copyWith(
                color: AppColors.kwhite.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: cryptoFavorites.map(
        (favorite) {
          final itemData = _getItemImage(favorite.symbol);
          return Column(
            children: [
              buildTrendingItem(
                favorite.image ?? (itemData['image']!.isNotEmpty ? itemData['image'] : null),
                favorite.symbol,
                favorite.name,
                itemData['percentage']!,
                _getTrendDirection(favorite.symbol),
                itemData['price']!,
              ),
              SizedBox(height: 12.h),
            ],
          );
        },
      ).toList(),
    );
  }

  Widget _buildMacroContent() {
    List<FavoriteItem> macroFavorites = _filterFavorites(_favoritesService.macroFavorites);

    if (macroFavorites.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: 50.h),
            Icon(
              Icons.public,
              size: 48.w,
              color: AppColors.kwhite.withOpacity(0.4),
            ),
            SizedBox(height: 16.h),
            Text(
              'No macro favorites yet',
              style: AppTextStyles.ktwhite16400.copyWith(
                color: AppColors.kwhite.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: macroFavorites.map(
        (favorite) {
          final itemData = _getItemImage(favorite.symbol);
          return Column(
            children: [
              buildTrendingItem(
                favorite.image ?? (itemData['image']!.isNotEmpty ? itemData['image'] : null),
                favorite.symbol,
                favorite.name,
                itemData['percentage']!,
                _getTrendDirection(favorite.symbol),
                itemData['price']!,
              ),
              SizedBox(height: 12.h),
            ],
          );
        },
      ).toList(),
    );
  }



}