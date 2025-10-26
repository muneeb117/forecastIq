import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forcast/core/constants/images.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../core/helpers/index.dart';
import '../../services/notification_service.dart';
import '../../services/selected_assets_service.dart';

class AlertsFrequencyScreen extends StatefulWidget {
  const AlertsFrequencyScreen({super.key});

  @override
  State<AlertsFrequencyScreen> createState() => _AlertsFrequencyScreenState();
}

class _AlertsFrequencyScreenState extends State<AlertsFrequencyScreen> {
  final NotificationService _notificationService = Get.find<NotificationService>();
  late final SelectedAssetsService _selectedAssetsService;

  String _selectedFrequency = 'Daily';
  final TextEditingController _dailyAlertsController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<AssetData> _searchResults = [];
  Timer? _debounceTimer;
  Timer? _snackbarDebounceTimer;
  bool _isUpdatingText = false;

  // Keys for SharedPreferences
  static const String _alertFrequencyKey = 'daily_alerts_frequency';
  static const String _selectedFrequencyKey = 'selected_frequency';

  // Real assets used in the app - from TradingAIService
  final List<AssetData> _allAssets = [
    // Crypto Assets (from TradingAIService.cryptoAssets)
    AssetData('BTC', 'Bitcoin', 'Crypto', 'crypto'),
    AssetData('ETH', 'Ethereum', 'Crypto', 'crypto'),
    AssetData('USDT', 'Tether', 'Crypto', 'crypto'),
    AssetData('XRP', 'Ripple', 'Crypto', 'crypto'),
    AssetData('BNB', 'Binance Coin', 'Crypto', 'crypto'),
    AssetData('SOL', 'Solana', 'Crypto', 'crypto'),
    AssetData('USDC', 'USD Coin', 'Crypto', 'crypto'),
    AssetData('DOGE', 'Dogecoin', 'Crypto', 'crypto'),
    AssetData('ADA', 'Cardano', 'Crypto', 'crypto'),
    AssetData('TRX', 'TRON', 'Crypto', 'crypto'),

    // Stock Assets (from TradingAIService.stockAssets)
    AssetData('NVDA', 'NVIDIA', 'Stock', 'stock'),
    AssetData('MSFT', 'Microsoft', 'Stock', 'stock'),
    AssetData('AAPL', 'Apple Inc.', 'Stock', 'stock'),
    AssetData('GOOGL', 'Google', 'Stock', 'stock'),
    AssetData('AMZN', 'Amazon', 'Stock', 'stock'),
    AssetData('META', 'Meta Platforms', 'Stock', 'stock'),
    AssetData('AVGO', 'Broadcom', 'Stock', 'stock'),
    AssetData('TSLA', 'Tesla', 'Stock', 'stock'),
    AssetData('BRK-B', 'Berkshire Hathaway', 'Stock', 'stock'),
    AssetData('JPM', 'JPMorgan Chase', 'Stock', 'stock'),

    // Macro Economic Indicators (from TradingAIService.macroAssets)
    AssetData('GDP', 'Gross Domestic Product', 'Macro', 'macro'),
    AssetData('CPI', 'Consumer Price Index', 'Macro', 'macro'),
    AssetData('UNEMPLOYMENT', 'Unemployment Rate', 'Macro', 'macro'),
    AssetData('FED_RATE', 'Federal Interest Rate', 'Macro', 'macro'),
    AssetData('CONSUMER_CONFIDENCE', 'Consumer Confidence Index', 'Macro', 'macro'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAssetsService = Get.put(SelectedAssetsService());
    _searchController.addListener(_onSearchChanged);
    _loadSavedSettings();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _dailyAlertsController.dispose();
    _debounceTimer?.cancel();
    _snackbarDebounceTimer?.cancel();
    super.dispose();
  }

  // Load saved settings from SharedPreferences
  Future<void> _loadSavedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFrequency = prefs.getInt(_alertFrequencyKey) ?? 0;
      final savedFrequencyType = prefs.getString(_selectedFrequencyKey) ?? 'Daily';

      if (mounted) {
        setState(() {
          _selectedFrequency = savedFrequencyType;
          // Only set text if there's a saved value > 0, otherwise keep it empty to show placeholder
          if (savedFrequency > 0) {
            _dailyAlertsController.text = savedFrequency.toString();
          }
        });
      }

      //print('✅ Loaded settings: $savedFrequency alerts, $_selectedFrequency frequency');
    } catch (e) {
      //print('Error loading saved settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings(int frequency, String frequencyType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_alertFrequencyKey, frequency);
      await prefs.setString(_selectedFrequencyKey, frequencyType);
    } catch (e) {
      //print('Error saving settings: $e');
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchResults = _allAssets.where((asset) {
        return asset.symbol.toLowerCase().contains(query) ||
               asset.name.toLowerCase().contains(query) ||
               asset.category.toLowerCase().contains(query);
      }).toList();
    });
  }

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
                    20.verticalSpace,

                    // Daily Alerts Frequency Input
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
                            width: 60.w,
                            height: 46.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: AppColors.kscoffald,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: TextField(
                                controller: _dailyAlertsController,
                                style: AppTextStyles.kmwhite16600,
                                decoration: InputDecoration(
                                  hintText: '00',
                                  hintStyle: AppTextStyles.kmwhite16600.copyWith(
                                    color: AppColors.kwhite.withValues(alpha: 0.5),
                                  ),
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                cursorColor: AppColors.kwhite,
                                onChanged: (value) {
                                  // Prevent recursive calls when we're updating the text programmatically
                                  if (_isUpdatingText) return;

                                  // Cancel previous timers
                                  _debounceTimer?.cancel();
                                  _snackbarDebounceTimer?.cancel();

                                  final alertCount = int.tryParse(value) ?? 0;

                                  // Validate maximum limit of 2400
                                  if (alertCount > 2400) {
                                    _isUpdatingText = true;

                                    // Use post frame callback to safely update the text after current frame
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (mounted) {
                                        _dailyAlertsController.text = '2400';
                                        _dailyAlertsController.selection = TextSelection.fromPosition(
                                          TextPosition(offset: _dailyAlertsController.text.length),
                                        );
                                        _isUpdatingText = false;
                                      }
                                    });

                                    MessageHelper.showWarning(
                                      'Maximum alert frequency is 2400',
                                      title: '⚠️ Limit Reached',
                                    );
                                    return;
                                  }

                                  // Save the value immediately for persistence
                                  if (alertCount > 0) {
                                    _saveSettings(alertCount, _selectedFrequency);
                                  }

                                  // No need to show frequency info - removed to avoid multiple alerts

                                  // Set timer to update alerts after user stops typing
                                  _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
                                    if (alertCount > 0 && _selectedAssetsService.selectedAssets.isNotEmpty) {
                                      _updateAlertsForAllSelectedAssets();
                                    }
                                  });
                                },
                                onSubmitted: (value) {
                                  // Update alerts when user finishes typing (presses enter)
                                  var alertCount = int.tryParse(value) ?? 0;

                                  // Validate maximum limit of 2400
                                  if (alertCount > 2400) {
                                    alertCount = 2400;
                                    _dailyAlertsController.text = '2400';
                                    _dailyAlertsController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: _dailyAlertsController.text.length),
                                    );
                                    MessageHelper.showWarning(
                                      'Maximum alert frequency is 2400',
                                      title: '⚠️ Limit Reached',
                                    );
                                  }

                                  if (alertCount > 0) {
                                    _saveSettings(alertCount, _selectedFrequency);
                                    _updateAlertsForAllSelectedAssets();
                                  }
                                },
                              ),
                            ),
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
                    24.verticalSpace,

                    // Choose Which asset trigger alerts
                    Text(
                      'Choose Which asset trigger alerts',
                      style: AppTextStyles.ktwhite16500,
                    ),
                    12.verticalSpace,

                    // Search field
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
                          hintText: 'Search Crypto, Stocks, Macro...',
                          hintStyle: AppTextStyles.kblack14500.copyWith(
                            color: AppColors.kwhite2,
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 20.w, right: 12.w),
                            child: SvgPicture.asset(
                              AppImages.search,
                              width: 18.w,
                              height: 18.h,
                              colorFilter: ColorFilter.mode(AppColors.kwhite, BlendMode.srcIn),
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


                    // Search Results
                    if (_searchResults.isNotEmpty) ...[
                      12.verticalSpace,
                      Container(
                        constraints: BoxConstraints(maxHeight: 200.h),
                        decoration: BoxDecoration(
                          color: AppColors.ksecondary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: _searchResults.map((asset) =>
                              _buildSearchResultItem(asset)
                            ).toList(),
                          ),
                        ),
                      ),
                    ],

                    12.verticalSpace,

                    // Selected Assets List
                    Obx(() {
                      final selectedAssets = _selectedAssetsService.selectedAssets;
                      if (selectedAssets.isNotEmpty) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Selected Assets',
                                  style: AppTextStyles.ktwhite16600,
                                ),
                                Text(
                                  '${selectedAssets.length} Assets',
                                  style: AppTextStyles.ktwhite14400.copyWith(
                                    color: AppColors.kprimary,
                                  ),
                                ),
                              ],
                            ),
                            12.verticalSpace,
                            ...selectedAssets.map((asset) => _buildAssetItem(asset)),
                          ],
                        );
                      }
                      return const SizedBox();
                    }),

                    32.verticalSpace,
                    40.verticalSpace,
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
        // Save the frequency type
        final alertCount = int.tryParse(_dailyAlertsController.text) ?? 0;
        _saveSettings(alertCount, frequency);
        // Update alerts silently without showing individual time notifications
        if (alertCount > 0 && _selectedAssetsService.selectedAssets.isNotEmpty) {
          _updateAlertsForAllSelectedAssets();
        }
      },
      child: Container(
        height: 54.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.ktertiary,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
            ? Border.all(color: AppColors.kprimary, width: 1)
            : null,
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
            Expanded(
              child: Text(
                frequency,
                style: AppTextStyles.kmwhite16600,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.kprimary,
                size: 20.r,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultItem(AssetData asset) {
    final isSelected = _selectedAssetsService.isAssetSelected(asset);

    return GestureDetector(
      onTap: () => _addAsset(asset),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.ktertiary, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorHelper.getAssetColor(asset.symbol),
              ),
              child: Center(
                child: AssetHelper.getAssetWidget(asset.symbol),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.symbol,
                    style: AppTextStyles.ktwhite14600,
                  ),
                  Text(
                    '${asset.name} • ${asset.category}',
                    style: AppTextStyles.kwhite14400.copyWith(
                      color: AppColors.kwhite.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.kprimary, size: 20.r)
            else
              Icon(Icons.add_circle_outline, color: AppColors.kwhite.withValues(alpha: 0.7), size: 20.r),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetItem(AssetData asset) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.ktertiary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorHelper.getAssetColor(asset.symbol),
              ),
              child: Center(child: AssetHelper.getAssetWidget(asset.symbol)),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    asset.symbol,
                    style: AppTextStyles.kblack14500.copyWith(color: AppColors.kwhite),
                  ),
                  Text(
                    '${asset.name} • ${asset.category}',
                    style: AppTextStyles.kblack12400.copyWith(
                      color: AppColors.kwhite.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _selectedAssetsService.removeAsset(asset);
                // Automatically cancel alerts for this asset
                _cancelAlertForAsset(asset);

                MessageHelper.showSuccess(
                  '${asset.symbol} removed and alerts cancelled',
                  title: 'Asset Removed',
                );
              },
              child: Container(
                padding: EdgeInsets.all(4.w),
                child: SvgPicture.asset(
                  AppImages.delete,
                  width: 20.w,
                  height: 20.h,
                  colorFilter: ColorFilter.mode(AppColors.kred, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _addAsset(AssetData asset) {
    if (!_selectedAssetsService.isAssetSelected(asset)) {
      _selectedAssetsService.addAsset(asset);
      setState(() {
        _searchController.clear();
        _searchResults.clear();
      });

      // Automatically setup alerts for this asset
      _setupAlertForAsset(asset);

      // Show simple success message without time details
      MessageHelper.showSuccess(
        '${asset.symbol} added successfully',
        title: 'Asset Added',
      );
    }
  }

  List<Map<String, dynamic>> _getDailyAlertsConfigs(AssetData asset, int alertCount) {
    if (alertCount <= 0) return [];

    final intervalMinutes = (24 * 60) / alertCount;
    final List<Map<String, dynamic>> configs = [];

    for (int i = 0; i < alertCount; i++) {
      final delayMinutes = intervalMinutes * i;
      final delay = Duration(minutes: delayMinutes.round());
      final alertNumber = i + 1;

      configs.add({
        'title': '📈 ${asset.symbol} Alert ($alertNumber/$alertCount)',
        'body': '${asset.name} daily update - Check the latest price and trends! Alert $alertNumber of $alertCount today.',
        'delay': delay,
        'type': 'daily_asset_alert',
        'payload': jsonEncode({
          'asset': asset.symbol,
          'alertNumber': alertNumber,
          'totalAlerts': alertCount,
          'frequency': 'daily'
        }),
      });
    }
    return configs;
  }

  List<Map<String, dynamic>> _getWeeklyAlertsConfigs(AssetData asset, int alertCount) {
    if (alertCount <= 0) return [];

    final intervalMinutes = (7 * 24 * 60) / alertCount;
    final List<Map<String, dynamic>> configs = [];

    for (int i = 0; i < alertCount; i++) {
      final delayMinutes = intervalMinutes * i;
      final delay = Duration(minutes: delayMinutes.round());
      final alertNumber = i + 1;
      final dayOfWeek = (delayMinutes / (24 * 60)).floor() + 1;

      configs.add({
        'title': '📊 ${asset.symbol} Weekly Alert ($alertNumber/$alertCount)',
        'body': '${asset.name} weekly update - Day $dayOfWeek analysis. Alert $alertNumber of $alertCount this week.',
        'delay': delay,
        'type': 'weekly_asset_alert',
        'payload': jsonEncode({
          'asset': asset.symbol,
          'alertNumber': alertNumber,
          'totalAlerts': alertCount,
          'frequency': 'weekly',
          'dayOfWeek': dayOfWeek
        }),
      });
    }
    return configs;
  }

  List<Map<String, dynamic>> _getRealTimeAlertsConfigs(AssetData asset, int alertCount) {
    if (alertCount <= 0) return [];

    final intervalMinutes = (24 * 60) / alertCount;
    final List<Map<String, dynamic>> configs = [];

    for (int i = 0; i < alertCount; i++) {
      final delayMinutes = intervalMinutes * i;
      final delay = Duration(minutes: delayMinutes.round());
      final alertNumber = i + 1;

      configs.add({
        'title': '⚡ ${asset.symbol} Real-time ($alertNumber/$alertCount)',
        'body': '${asset.name} real-time update - Live market analysis! Alert $alertNumber of $alertCount today.',
        'delay': delay,
        'type': 'realtime_asset_alert',
        'payload': jsonEncode({
          'asset': asset.symbol,
          'alertNumber': alertNumber,
          'totalAlerts': alertCount,
          'frequency': 'realtime'
        }),
      });
    }
    return configs;
  }

  void _setupAlertForAsset(AssetData asset) {
    final alertCount = int.tryParse(_dailyAlertsController.text) ?? 0;
    if (alertCount <= 0) return;

    List<Map<String, dynamic>> configs = [];
    switch (_selectedFrequency) {
      case 'Daily':
        configs = _getDailyAlertsConfigs(asset, alertCount);
        break;
      case 'Weekly':
        configs = _getWeeklyAlertsConfigs(asset, alertCount);
        break;
      case 'Real Time':
        configs = _getRealTimeAlertsConfigs(asset, alertCount);
        break;
    }

    if (configs.isNotEmpty) {
      _notificationService.scheduleMultipleNotifications(notificationConfigs: configs);
    }
  }

  void _cancelAlertForAsset(AssetData asset) {
    // Cancel any scheduled notifications for this asset
    // Note: In a production app, you'd want to track notification IDs per asset
    // For now, we'll just clear and reschedule all remaining assets
    _notificationService.clearAllNotifications();

    // Reschedule alerts for remaining assets
    _updateAlertsForAllSelectedAssets();
  }

  void _updateAlertsForAllSelectedAssets() {
    // Clear all current notifications
    _notificationService.clearAllNotifications();

    final alertCount = int.tryParse(_dailyAlertsController.text) ?? 0;
    if (alertCount <= 0) {
      return;
    }

    final List<Map<String, dynamic>> allNotificationConfigs = [];

    // Prepare configs for all selected assets
    for (final asset in _selectedAssetsService.selectedAssets) {
      switch (_selectedFrequency) {
        case 'Daily':
          allNotificationConfigs.addAll(_getDailyAlertsConfigs(asset, alertCount));
          break;
        case 'Weekly':
          allNotificationConfigs.addAll(_getWeeklyAlertsConfigs(asset, alertCount));
          break;
        case 'Real Time':
          allNotificationConfigs.addAll(_getRealTimeAlertsConfigs(asset, alertCount));
          break;
      }
    }

    // Schedule all notifications at once
    if (allNotificationConfigs.isNotEmpty) {
      _notificationService.scheduleMultipleNotifications(notificationConfigs: allNotificationConfigs);
    }

    final selectedCount = _selectedAssetsService.selectedAssets.length;

    if (selectedCount > 0) {
      MessageHelper.showSuccess(
        'Updated $selectedCount assets with $_selectedFrequency frequency ($alertCount alerts each)',
        title: '🔄 Alerts Updated',
        duration: const Duration(seconds: 3),
      );
    }
  }
}