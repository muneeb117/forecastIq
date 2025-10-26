import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service class to handle iOS-specific configurations and communications
class IOSConfigurationService {
  // Method channels for iOS communication
  static const MethodChannel _notificationChannel = MethodChannel('com.forcast.app/notifications');
  static const MethodChannel _backgroundChannel = MethodChannel('com.forcast.app/background');
  static const MethodChannel _deeplinkChannel = MethodChannel('com.forcast.app/deeplink');

  static IOSConfigurationService? _instance;
  static IOSConfigurationService get instance => _instance ??= IOSConfigurationService._internal();

  IOSConfigurationService._internal();

  /// Initialize iOS-specific configurations
  Future<void> initialize() async {
    if (!defaultTargetPlatform.name.toLowerCase().contains('ios')) return;

    try {
      // Set up method channel handlers
      _setupNotificationHandler();
      _setupBackgroundHandler();
      _setupDeepLinkHandler();

      print('✅ iOS Configuration Service initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize iOS Configuration Service: $e');
    }
  }

  /// Set up notification handling from iOS
  void _setupNotificationHandler() {
    _notificationChannel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'handleNotificationTap':
          await _handleNotificationTap(call.arguments);
          break;
        default:
          print('Unknown notification method: ${call.method}');
      }
    });
  }

  /// Set up background task handling from iOS
  void _setupBackgroundHandler() {
    _backgroundChannel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'performBackgroundFetch':
          return await _performBackgroundFetch();
        default:
          print('Unknown background method: ${call.method}');
          return null;
      }
    });
  }

  /// Set up deep link handling from iOS
  void _setupDeepLinkHandler() {
    _deeplinkChannel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'handleDeepLink':
          await _handleDeepLink(call.arguments as String);
          break;
        default:
          print('Unknown deep link method: ${call.method}');
      }
    });
  }

  /// Handle notification tap from iOS
  Future<void> _handleNotificationTap(dynamic arguments) async {
    try {
      if (arguments is Map) {
        String type = arguments['type'] ?? '';
        Map<String, dynamic> data = Map<String, dynamic>.from(arguments['data'] ?? {});

        print('📱 Notification tapped - Type: $type, Data: $data');

        // Handle different notification types
        switch (type) {
          case 'price_alert':
            await _handlePriceAlertNotification(data);
            break;
          case 'trading_alert':
            await _handleTradingAlertNotification(data);
            break;
          case 'portfolio_update':
            await _handlePortfolioUpdateNotification(data);
            break;
          default:
            print('Unknown notification type: $type');
        }
      }
    } catch (e) {
      print('Error handling notification tap: $e');
    }
  }

  /// Handle background fetch request from iOS
  Future<bool> _performBackgroundFetch() async {
    try {
      print('🔄 Performing background fetch...');

      // Perform background tasks here
      // Examples:
      // - Sync portfolio data
      // - Update price alerts
      // - Refresh trading recommendations
      // - Update user preferences

      // Simulate background work
      await Future.delayed(const Duration(seconds: 2));

      // Return true if new data was fetched, false otherwise
      return true;
    } catch (e) {
      print('Error during background fetch: $e');
      return false;
    }
  }

  /// Handle deep link from iOS
  Future<void> _handleDeepLink(String url) async {
    try {
      print('🔗 Deep link received: $url');

      Uri uri = Uri.parse(url);
      String scheme = uri.scheme;
      String host = uri.host;
      String path = uri.path;
      Map<String, String> params = uri.queryParameters;

      print('Scheme: $scheme, Host: $host, Path: $path, Params: $params');

      // Handle different deep link patterns
      if (scheme == 'forcast') {
        switch (host) {
          case 'coin':
            await _handleCoinDeepLink(path, params);
            break;
          case 'portfolio':
            await _handlePortfolioDeepLink(path, params);
            break;
          case 'settings':
            await _handleSettingsDeepLink(path, params);
            break;
          default:
            print('Unknown deep link host: $host');
        }
      }
    } catch (e) {
      print('Error handling deep link: $e');
    }
  }

  /// Handle price alert notification
  Future<void> _handlePriceAlertNotification(Map<String, dynamic> data) async {
    String? coinId = data['coin_id'];
    String? alertType = data['alert_type'];
    double? price = double.tryParse(data['price']?.toString() ?? '');

    print('💰 Price Alert - Coin: $coinId, Type: $alertType, Price: \$${price?.toStringAsFixed(2)}');

    // Navigate to coin detail screen
    if (coinId != null) {
      // Use your navigation service to navigate to coin detail
      // NavigationService.instance.navigateToCoinDetail(coinId);
    }
  }

  /// Handle trading alert notification
  Future<void> _handleTradingAlertNotification(Map<String, dynamic> data) async {
    String? alertType = data['alert_type'];
    String? message = data['message'];

    print('📊 Trading Alert - Type: $alertType, Message: $message');

    // Navigate to trading screen or show alert dialog
    // NavigationService.instance.navigateToTrading();
  }

  /// Handle portfolio update notification
  Future<void> _handlePortfolioUpdateNotification(Map<String, dynamic> data) async {
    String? updateType = data['update_type'];
    double? change = double.tryParse(data['change']?.toString() ?? '');

    print('💼 Portfolio Update - Type: $updateType, Change: ${change?.toStringAsFixed(2)}%');

    // Navigate to portfolio screen
    // NavigationService.instance.navigateToPortfolio();
  }

  /// Handle coin deep link
  Future<void> _handleCoinDeepLink(String path, Map<String, String> params) async {
    List<String> pathSegments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (pathSegments.isNotEmpty) {
      String coinId = pathSegments[0];
      String? tab = params['tab'];

      print('🪙 Opening coin: $coinId, Tab: $tab');

      // Navigate to coin detail with specific tab
      // NavigationService.instance.navigateToCoinDetail(coinId, tab: tab);
    }
  }

  /// Handle portfolio deep link
  Future<void> _handlePortfolioDeepLink(String path, Map<String, String> params) async {
    String? section = params['section'];

    print('💼 Opening portfolio, Section: $section');

    // Navigate to portfolio with specific section
    // NavigationService.instance.navigateToPortfolio(section: section);
  }

  /// Handle settings deep link
  Future<void> _handleSettingsDeepLink(String path, Map<String, String> params) async {
    List<String> pathSegments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (pathSegments.isNotEmpty) {
      String settingsPage = pathSegments[0];

      print('⚙️ Opening settings page: $settingsPage');

      // Navigate to specific settings page
      // NavigationService.instance.navigateToSettings(settingsPage);
    }
  }

  /// Request iOS notifications permission
  Future<bool> requestNotificationPermission() async {
    if (!defaultTargetPlatform.name.toLowerCase().contains('ios')) return false;

    try {
      final bool? granted = await _notificationChannel.invokeMethod('requestPermission');
      return granted ?? false;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Get iOS device token for push notifications
  Future<String?> getDeviceToken() async {
    if (!defaultTargetPlatform.name.toLowerCase().contains('ios')) return null;

    try {
      final String? token = await _notificationChannel.invokeMethod('getDeviceToken');
      return token;
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }

  /// Schedule local notification on iOS
  Future<void> scheduleLocalNotification({
    required String title,
    required String body,
    String? category,
    Map<String, dynamic>? userInfo,
    DateTime? scheduleTime,
  }) async {
    if (!defaultTargetPlatform.name.toLowerCase().contains('ios')) return;

    try {
      await _notificationChannel.invokeMethod('scheduleNotification', {
        'title': title,
        'body': body,
        'category': category ?? 'default',
        'userInfo': userInfo ?? {},
        'scheduleTime': scheduleTime?.millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error scheduling local notification: $e');
    }
  }

  /// Update iOS app badge count
  Future<void> updateBadgeCount(int count) async {
    if (!defaultTargetPlatform.name.toLowerCase().contains('ios')) return;

    try {
      await _notificationChannel.invokeMethod('updateBadge', {'count': count});
    } catch (e) {
      print('Error updating badge count: $e');
    }
  }

  /// Clear all iOS notifications
  Future<void> clearAllNotifications() async {
    if (!defaultTargetPlatform.name.toLowerCase().contains('ios')) return;

    try {
      await _notificationChannel.invokeMethod('clearAllNotifications');
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  /// Check if iOS app is running in background
  Future<bool> isRunningInBackground() async {
    if (!defaultTargetPlatform.name.toLowerCase().contains('ios')) return false;

    try {
      final bool? inBackground = await _backgroundChannel.invokeMethod('isInBackground');
      return inBackground ?? false;
    } catch (e) {
      print('Error checking background state: $e');
      return false;
    }
  }

  /// Enable/disable iOS background refresh
  Future<void> setBackgroundRefreshEnabled(bool enabled) async {
    if (!defaultTargetPlatform.name.toLowerCase().contains('ios')) return;

    try {
      await _backgroundChannel.invokeMethod('setBackgroundRefresh', {'enabled': enabled});
    } catch (e) {
      print('Error setting background refresh: $e');
    }
  }
}