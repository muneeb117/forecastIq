import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class NotificationService extends GetxController {
  static NotificationService get instance => Get.find();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  RxBool isInitialized = false.obs;

  // Scheduled notifications list
  RxList<ScheduledNotification> scheduledNotifications = <ScheduledNotification>[].obs;

  // Notification history list (saved notifications)
  RxList<NotificationHistory> notificationHistory = <NotificationHistory>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeNotifications();
    loadScheduledNotifications();
    loadNotificationHistory();
  }

  // Initialize notifications
  Future<void> initializeNotifications() async {
    try {
      // Android settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      // Initialize WorkManager for background tasks
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      isInitialized.value = true;
      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Always navigate to notifications list screen when any notification is tapped
    print('Notification tapped: ${response.payload}');

    // Save the notification to history if it's not already there
    _saveReceivedNotificationToHistory(response);

    // Navigate to the notifications list
    try {
      // Navigate to notifications list screen
      Get.toNamed('/notifications');
    } catch (e) {
      print('Error navigating to notifications list: $e');
    }
  }

  // Handle background notification tap
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    print('Background notification tapped: ${response.payload}');
    // Background notifications will be handled when app comes to foreground
  }

  // Handle different notification actions
  void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'market_update':
        // Navigate to market screen
        Get.toNamed('/market');
        break;
      case 'price_alert':
        // Navigate to specific coin
        Get.toNamed('/coin/${data['coinId']}');
        break;
      case 'portfolio_update':
        // Navigate to portfolio
        Get.toNamed('/portfolio');
        break;
      case 'forecast_reminder':
        // Navigate to forecasts
        Get.toNamed('/forecast');
        break;
      default:
        break;
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
    String? coinSymbol,
    String? coinImage,
    String? type,
  }) async {
    if (!isInitialized.value) {
      print('Notification service not initialized');
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'forecast_channel',
      'Forecast Notifications',
      channelDescription: 'Notifications for crypto forecasts and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId = id ?? Random().nextInt(1000000);

    await _localNotifications.show(
      notificationId,
      title,
      body,
      details,
      payload: payload,
    );

    // Save notification to history
    await _saveNotificationToHistory(
      id: notificationId,
      title: title,
      body: body,
      coinSymbol: coinSymbol,
      coinImage: coinImage,
      type: type ?? 'general',
      payload: payload,
    );
  }

  // Schedule notification after specific duration
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    String? payload,
    int? id,
    String? type,
  }) async {
    final notificationId = id ?? Random().nextInt(1000000);
    final scheduledTime = DateTime.now().add(delay);

    // Create scheduled notification object
    final scheduledNotif = ScheduledNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      payload: payload,
      type: type ?? 'general',
    );

    // Add to list
    scheduledNotifications.add(scheduledNotif);
    saveScheduledNotifications();

    // Use Timer for short durations (less than 15 minutes)
    if (delay.inMinutes < 15) {
      Timer(delay, () async {
        // Extract coin info from payload
        String? coinSymbol;
        String? coinImage;
        if (payload != null) {
          try {
            final data = jsonDecode(payload);
            coinSymbol = data['asset'] as String?;
            coinImage = _getCoinImage(coinSymbol);
          } catch (e) {
            print('Error parsing payload for coin info: $e');
          }
        }

        await showNotification(
          title: title,
          body: body,
          payload: payload,
          id: notificationId,
          coinSymbol: coinSymbol,
          coinImage: coinImage,
          type: type,
        );

        // Remove from scheduled list
        scheduledNotifications.removeWhere((n) => n.id == notificationId);
        saveScheduledNotifications();
      });
    } else {
      // Use WorkManager for longer durations
      await Workmanager().registerOneOffTask(
        'notification_$notificationId',
        'showScheduledNotification',
        initialDelay: delay,
        inputData: {
          'id': notificationId,
          'title': title,
          'body': body,
          'payload': payload ?? '',
          'type': type ?? 'general',
        },
      );
    }

    Get.snackbar(
      'Notification Scheduled',
      'You will receive a notification in ${_formatDuration(delay)}',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Cancel scheduled notification
  Future<void> cancelScheduledNotification(int id) async {
    await Workmanager().cancelByUniqueName('notification_$id');
    scheduledNotifications.removeWhere((n) => n.id == id);
    saveScheduledNotifications();

    Get.snackbar(
      'Notification Cancelled',
      'Scheduled notification has been cancelled',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Schedule daily reminder
  Future<void> scheduleDailyReminder({
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year, now.month, now.day, time.hour, time.minute
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final duration = scheduledTime.difference(now);

    await scheduleNotification(
      title: title,
      body: body,
      delay: duration,
      payload: payload,
      type: 'daily_reminder',
    );

    // Schedule recurring daily notifications using WorkManager
    await Workmanager().registerPeriodicTask(
      'daily_reminder',
      'showDailyReminder',
      frequency: const Duration(days: 1),
      initialDelay: duration,
      inputData: {
        'title': title,
        'body': body,
        'payload': payload ?? '',
        'hour': time.hour,
        'minute': time.minute,
      },
    );
  }

  // Market update notifications
  Future<void> scheduleMarketUpdateNotifications() async {
    // Morning market summary
    await scheduleDailyReminder(
      title: '🌅 Good Morning!',
      body: 'Check your portfolio and today\'s market trends',
      time: const TimeOfDay(hour: 9, minute: 0),
      payload: jsonEncode({'type': 'market_update', 'time': 'morning'}),
    );

    // Evening market summary
    await scheduleDailyReminder(
      title: '🌆 Market Summary',
      body: 'See how your investments performed today',
      time: const TimeOfDay(hour: 18, minute: 0),
      payload: jsonEncode({'type': 'market_update', 'time': 'evening'}),
    );
  }

  // Forecast reminder notifications
  Future<void> scheduleForecastReminders() async {
    // Weekly forecast check
    await scheduleNotification(
      title: '📈 Weekly Forecast',
      body: 'Time to check your crypto forecasts and predictions',
      delay: const Duration(days: 7),
      payload: jsonEncode({'type': 'forecast_reminder'}),
    );

    // Monthly investment review
    await scheduleNotification(
      title: '📊 Monthly Review',
      body: 'Review your investment performance this month',
      delay: const Duration(days: 30),
      payload: jsonEncode({'type': 'portfolio_update'}),
    );
  }

  // Custom timed notifications
  Future<void> showTimedNotifications() async {
    // Welcome back notification (after 1 hour)
    await scheduleNotification(
      title: '👋 Welcome Back!',
      body: 'Check out the latest crypto trends and forecasts',
      delay: const Duration(hours: 1),
      type: 'welcome_back',
    );

    // Engagement notification (after 3 hours)
    await scheduleNotification(
      title: '🔥 Don\'t Miss Out!',
      body: 'New market insights are available in your app',
      delay: const Duration(hours: 3),
      type: 'engagement',
    );

    // Daily check-in (after 24 hours)
    await scheduleNotification(
      title: '📱 Daily Check-in',
      body: 'Your daily crypto market update is ready',
      delay: const Duration(hours: 24),
      type: 'daily_checkin',
    );
  }

  // Price alert notifications
  Future<void> schedulePriceAlert({
    required String coinName,
    required double targetPrice,
    required bool isAbove, // true for above, false for below
  }) async {
    final condition = isAbove ? 'above' : 'below';

    await scheduleNotification(
      title: '🚨 Price Alert: $coinName',
      body: '$coinName has reached $condition \$${targetPrice.toStringAsFixed(2)}!',
      delay: const Duration(minutes: 30), // Check in 30 minutes
      payload: jsonEncode({
        'type': 'price_alert',
        'coinName': coinName,
        'targetPrice': targetPrice,
        'condition': condition,
      }),
      type: 'price_alert',
    );
  }

  // Save scheduled notifications to preferences
  Future<void> saveScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = scheduledNotifications
        .map((n) => jsonEncode(n.toMap()))
        .toList();
    await prefs.setStringList('scheduled_notifications', jsonList);
  }

  // Load scheduled notifications from preferences
  Future<void> loadScheduledNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? jsonList = prefs.getStringList('scheduled_notifications');

      if (jsonList != null) {
        scheduledNotifications.value = jsonList
            .map((json) => ScheduledNotification.fromMap(jsonDecode(json)))
            .where((n) => n.scheduledTime.isAfter(DateTime.now())) // Only future notifications
            .toList();
      }
    } catch (e) {
      print('Error loading scheduled notifications: $e');
    }
  }

  // Save notification to history
  Future<void> _saveNotificationToHistory({
    required int id,
    required String title,
    required String body,
    String? coinSymbol,
    String? coinImage,
    required String type,
    String? payload,
  }) async {
    final notification = NotificationHistory(
      id: id,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      coinSymbol: coinSymbol,
      coinImage: coinImage ?? _getCoinImage(coinSymbol),
      type: type,
      payload: payload,
      isRead: false,
    );

    await _addNotificationToHistory(notification);
  }

  // Save received notification to history (when tapped or received)
  Future<void> _saveReceivedNotificationToHistory(NotificationResponse response) async {
    final notificationId = response.id ?? Random().nextInt(1000000);

    // Check if notification already exists in history
    final existingIndex = notificationHistory.indexWhere((n) => n.id == notificationId);
    if (existingIndex != -1) {
      return; // Notification already exists
    }

    // Parse notification data from payload
    String? coinSymbol;
    String? coinImage;
    String type = 'general';

    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final data = jsonDecode(response.payload!);
        coinSymbol = data['asset'] as String? ?? data['coinSymbol'] as String?;
        type = data['type'] as String? ?? 'general';
        coinImage = _getCoinImage(coinSymbol);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }

    // Create notification history entry
    final notification = NotificationHistory(
      id: notificationId,
      title: response.notificationResponseType == NotificationResponseType.selectedNotification
          ? 'Notification Received'
          : 'Notification Action',
      body: 'Notification received at ${DateTime.now().toString().substring(11, 16)}',
      timestamp: DateTime.now(),
      coinSymbol: coinSymbol,
      coinImage: coinImage,
      type: type,
      payload: response.payload,
      isRead: false,
    );

    await _addNotificationToHistory(notification);
  }

  // Common method to add notification to history
  Future<void> _addNotificationToHistory(NotificationHistory notification) async {
    notificationHistory.insert(0, notification); // Add to beginning

    // Keep only last 100 notifications
    if (notificationHistory.length > 100) {
      notificationHistory.removeRange(100, notificationHistory.length);
    }

    await _saveNotificationHistory();
  }

  // Get coin image path
  String? _getCoinImage(String? coinSymbol) {
    if (coinSymbol == null) return null;

    // Map coin symbols to image paths
    final coinImages = {
      'BTC': 'assets/images/btc.png',
      'ETH': 'assets/images/eth.png',
      'USDT': 'assets/images/usdt.png',
      'XRP': 'assets/images/xrp.png',
      'BNB': 'assets/images/bnb.png',
      'SOL': 'assets/images/sol.png',
      'USDC': 'assets/images/usdc.png',
      'DOGE': 'assets/images/doge.png',
      'ADA': 'assets/images/ada.png',
      'TRX': 'assets/images/trx.png',
    };

    return coinImages[coinSymbol.toUpperCase()];
  }

  // Save notification history to storage
  Future<void> _saveNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> jsonList = notificationHistory
          .map((n) => jsonEncode(n.toMap()))
          .toList();
      await prefs.setStringList('notification_history', jsonList);
    } catch (e) {
      print('Error saving notification history: $e');
    }
  }

  // Public method to save notification history (for testing purposes)
  Future<void> saveNotificationHistory() async {
    await _saveNotificationHistory();
  }

  // Load notification history from storage
  Future<void> loadNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? jsonList = prefs.getStringList('notification_history');

      if (jsonList != null) {
        notificationHistory.value = jsonList
            .map((json) => NotificationHistory.fromMap(jsonDecode(json)))
            .toList();
      }
    } catch (e) {
      print('Error loading notification history: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    final index = notificationHistory.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notificationHistory[index] = notificationHistory[index].copyWith(isRead: true);
      await _saveNotificationHistory();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (int i = 0; i < notificationHistory.length; i++) {
      notificationHistory[i] = notificationHistory[i].copyWith(isRead: true);
    }
    await _saveNotificationHistory();
  }

  // Delete notification from history
  Future<void> deleteNotification(int notificationId) async {
    notificationHistory.removeWhere((n) => n.id == notificationId);
    await _saveNotificationHistory();
  }

  // Clear all notification history
  Future<void> clearNotificationHistory() async {
    notificationHistory.clear();
    await _saveNotificationHistory();
  }

  // Handle received notification (called when notification is received while app is running)
  Future<void> handleReceivedNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
    String? coinSymbol,
    String? coinImage,
    String? type,
  }) async {
    final notificationId = id ?? Random().nextInt(1000000);

    // Parse additional data from payload if available
    if (payload != null && payload.isNotEmpty) {
      try {
        final data = jsonDecode(payload);
        coinSymbol ??= data['asset'] as String? ?? data['coinSymbol'] as String?;
        type ??= data['type'] as String? ?? 'general';
        coinImage ??= _getCoinImage(coinSymbol);
      } catch (e) {
        print('Error parsing received notification payload: $e');
      }
    }

    final notification = NotificationHistory(
      id: notificationId,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      coinSymbol: coinSymbol,
      coinImage: coinImage ?? _getCoinImage(coinSymbol),
      type: type ?? 'general',
      payload: payload,
      isRead: false,
    );

    await _addNotificationToHistory(notification);

    print('📱 Notification received and saved to history: $title');
  }

  // Get unread count
  int get unreadCount => notificationHistory.where((n) => !n.isRead).length;

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
    await Workmanager().cancelAll();
    scheduledNotifications.clear();
    await saveScheduledNotifications();

    Get.snackbar(
      'Notifications Cleared',
      'All notifications have been cancelled',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Format duration for display
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }
}

// Scheduled notification model
class ScheduledNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String? payload;
  final String type;

  ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    this.payload,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      'payload': payload,
      'type': type,
    };
  }

  factory ScheduledNotification.fromMap(Map<String, dynamic> map) {
    return ScheduledNotification(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(map['scheduledTime']),
      payload: map['payload'],
      type: map['type'],
    );
  }
}

// Notification history model
class NotificationHistory {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String? coinSymbol;
  final String? coinImage;
  final String type;
  final String? payload;
  final bool isRead;

  NotificationHistory({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.coinSymbol,
    this.coinImage,
    required this.type,
    this.payload,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'coinSymbol': coinSymbol,
      'coinImage': coinImage,
      'type': type,
      'payload': payload,
      'isRead': isRead,
    };
  }

  factory NotificationHistory.fromMap(Map<String, dynamic> map) {
    return NotificationHistory(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      coinSymbol: map['coinSymbol'],
      coinImage: map['coinImage'],
      type: map['type'] ?? 'general',
      payload: map['payload'],
      isRead: map['isRead'] ?? false,
    );
  }

  NotificationHistory copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? coinSymbol,
    String? coinImage,
    String? type,
    String? payload,
    bool? isRead,
  }) {
    return NotificationHistory(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      coinSymbol: coinSymbol ?? this.coinSymbol,
      coinImage: coinImage ?? this.coinImage,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      isRead: isRead ?? this.isRead,
    );
  }
}

// WorkManager callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'showScheduledNotification':
        await _showWorkManagerNotification(inputData!);
        break;
      case 'showDailyReminder':
        await _showDailyReminderNotification(inputData!);
        break;
    }
    return Future.value(true);
  });
}

// Show notification from WorkManager
Future<void> _showWorkManagerNotification(Map<String, dynamic> data) async {
  final notifications = FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'forecast_channel',
    'Forecast Notifications',
    channelDescription: 'Notifications for crypto forecasts and updates',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails details = NotificationDetails(android: androidDetails);

  await notifications.show(
    data['id'],
    data['title'],
    data['body'],
    details,
    payload: data['payload'],
  );
}

// Show daily reminder notification
Future<void> _showDailyReminderNotification(Map<String, dynamic> data) async {
  final notifications = FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'daily_reminder_channel',
    'Daily Reminders',
    channelDescription: 'Daily reminder notifications',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails details = NotificationDetails(android: androidDetails);

  await notifications.show(
    Random().nextInt(1000000),
    data['title'],
    data['body'],
    details,
    payload: data['payload'],
  );
}