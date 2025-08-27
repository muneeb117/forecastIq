import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import '../core/constants/colors.dart';
import '../core/constants/fonts.dart';

class AlertsFrequencyScreen extends StatefulWidget {
  const AlertsFrequencyScreen({super.key});

  @override
  State<AlertsFrequencyScreen> createState() => _AlertsFrequencyScreenState();
}

class _AlertsFrequencyScreenState extends State<AlertsFrequencyScreen> {
  String _selectedFrequency = 'Daily';
  List<String> _selectedAssets = ['BTC', 'ETH', 'REV'];
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kscoffald,
      body: SafeArea(
        child: Column(
          children: [
            // Header - Fixed at top
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
                  Text('Alerts & Frequency', style: AppTextStyles.ktwhite16500),
                  SizedBox(width: 24.w),
                ],
              ),
            ),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    40.verticalSpace,

                    // Daily Alerts Frequency Header
                    Container(
                      height: 54.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
                      decoration: BoxDecoration(
                        color: AppColors.ktertiary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Alerts Frequency',
                            style: AppTextStyles.ktwhite16400,
                          ),
                          Container(
                            width: 52.w,
                            height: 46.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 0.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.kscoffald,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: TextField(
                                style: AppTextStyles.kmwhite16600,
                                decoration: InputDecoration(
                                  hintText: '00',
                                  hintStyle: AppTextStyles.kmwhite16600,
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                cursorColor: AppColors.kwhite,
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                    12.verticalSpace,

                    // Select Frequency Section
                    Text('Select Frequency', style: AppTextStyles.kmwhite16600),
                    12.verticalSpace,

                    // Frequency Options
                    _buildFrequencyOption('Daily'),
                    12.verticalSpace,
                    _buildFrequencyOption('Weekly'),
                    12.verticalSpace,
                    _buildFrequencyOption('Real Time'),
                    12.verticalSpace,

                    // Choose Which asset trigger alerts
                    Text(
                      'Choose Which asset trigger alerts',
                      style: AppTextStyles.ktwhite16500,
                    ),
                    12.verticalSpace,
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
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Choose Assets',
                          hintStyle: AppTextStyles.kblack14500.copyWith(
                            color: AppColors.kwhite2,
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                              left: 20.w,
                              right: 12.w,
                            ),
                            child: SvgPicture.asset(
                              AppImages.search,
                              width: 18.w,
                              height: 18.h,
                              color: AppColors.kwhite,
                              fit: BoxFit.contain,
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 18.w,
                            minHeight: 18.h,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16.h,
                          ),
                        ),
                      ),
                    ),
                    12.verticalSpace,

                    // Selected Assets List
                    ..._selectedAssets.map((asset) => _buildAssetItem(asset)),
                    
                    12.verticalSpace,
                    
                    // Assets Count
                    Center(
                      child: Text(
                        '${_selectedAssets.length} Assets',
                        style: AppTextStyles.ktwhite16600,
                      ),
                    ),
                    
                    20.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyOption(String frequency) {
    bool isSelected = _selectedFrequency == frequency;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFrequency = frequency;
        });
      },
      child: Container(
        height: 54.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
        decoration: BoxDecoration(
          color: AppColors.ktertiary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.kwhite, width: 2.5),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.kwhite,
                        ),
                      ),
                    )
                  : null,
            ),
            15.horizontalSpace,
            Text(frequency, style: AppTextStyles.kmwhite16600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetItem(String asset) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        height: 54.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.ktertiary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getAssetColor(asset),
              ),
              child: Center(child: _getAssetWidget(asset)),
            ),
            12.horizontalSpace,
            Expanded(child: Text(asset, style: AppTextStyles.kblack14500.copyWith(
              color: AppColors.kwhite
            ))),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAssets.remove(asset);
                });
              },
              child: SvgPicture.asset(AppImages.delete,
                width: 24.w,
                height: 24.h,
              )
            ),
          ],
        ),
      ),
    );
  }

  Color _getAssetColor(String asset) {
    switch (asset) {
      case 'BTC':
        return Color(0xFFF7931A); // Bitcoin orange
      case 'ETH':
        return Color(0xFF627EEA); // Ethereum// blue
      case 'REV':
        return Color(0xFF8B5CF6); // Purple
      default:
        return AppColors.kprimary;
    }
  }

  Widget _getAssetWidget(String asset) {
    String assetImage;
    switch (asset) {
      case 'BTC':
        assetImage = AppImages.btc;
        break;
      case 'ETH':
        assetImage = AppImages.eth;
        break;
      case 'REV':
        assetImage = AppImages.rev;
        break;
      default:
        return Text(
          asset[0],
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        );
    }
    
    return Image.asset(
      assetImage,
      width: 20.w,
      height: 20.h,
      fit: BoxFit.contain,
    );
  }

  void _showAssetSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.ktertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text('Select Assets', style: AppTextStyles.ktwhite16600),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAssetDialogOption('BTC'),
            _buildAssetDialogOption('ETH'),
            _buildAssetDialogOption('REV'),
            _buildAssetDialogOption('USDT'),
            _buildAssetDialogOption('BNB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done',
              style: AppTextStyles.ktwhite14500.copyWith(
                color: AppColors.kprimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetDialogOption(String asset) {
    bool isSelected = _selectedAssets.contains(asset);

    return CheckboxListTile(
      value: isSelected,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            if (!_selectedAssets.contains(asset)) {
              _selectedAssets.add(asset);
            }
          } else {
            _selectedAssets.remove(asset);
          }
        });
        Navigator.pop(context);
        _showAssetSelectionDialog();
      },
      title: Text(asset, style: AppTextStyles.ktwhite14500),
      activeColor: AppColors.kprimary,
      checkColor: AppColors.kwhite,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
