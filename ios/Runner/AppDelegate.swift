import Flutter
import UIKit
import UserNotifications
import flutter_local_notifications
import AuthenticationServices

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Register Flutter plugins first
    GeneratedPluginRegistrant.register(with: self)

    // Configure notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    // Request notification permissions
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert, .providesAppNotificationSettings]) { granted, error in
        if granted {
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
        }
      }
    }

    // Configure notification categories and actions
    configureNotificationCategories()

    // Set application icon badge to zero on startup
    UIApplication.shared.applicationIconBadgeNumber = 0

    // Enable background refresh
    UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

    // Setup Apple Sign In credential state monitoring
    setupAppleSignInStateMonitoring()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Notification Configuration

  func configureNotificationCategories() {
    if #available(iOS 10.0, *) {
      // Trading Alert Category
      let tradingAlertAction = UNNotificationAction(
        identifier: "TRADING_ALERT_ACTION",
        title: "View Details",
        options: [.foreground]
      )

      let tradingCategory = UNNotificationCategory(
        identifier: "TRADING_ALERT",
        actions: [tradingAlertAction],
        intentIdentifiers: [],
        options: []
      )

      // Price Alert Category
      let priceAlertAction = UNNotificationAction(
        identifier: "PRICE_ALERT_ACTION",
        title: "Open App",
        options: [.foreground]
      )

      let dismissAction = UNNotificationAction(
        identifier: "DISMISS_ACTION",
        title: "Dismiss",
        options: []
      )

      let priceCategory = UNNotificationCategory(
        identifier: "PRICE_ALERT",
        actions: [priceAlertAction, dismissAction],
        intentIdentifiers: [],
        options: []
      )

      // Register categories
      UNUserNotificationCenter.current().setNotificationCategories([tradingCategory, priceCategory])
    }
  }

  // MARK: - Push Notification Handling

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Convert device token to string
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("Device Token: \(token)")

    // You can send this token to your server
    UserDefaults.standard.set(token, forKey: "deviceToken")

    // Call super method
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register for remote notifications: \(error)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // Handle notification when app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Show notification even when app is in foreground
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  // Handle notification tap
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo

    // Handle different notification actions
    switch response.actionIdentifier {
    case "TRADING_ALERT_ACTION", "PRICE_ALERT_ACTION":
      // Open specific screen in the app
      handleNotificationAction(userInfo: userInfo)
    case "DISMISS_ACTION":
      // Just dismiss the notification
      break
    default:
      // Default tap action - open app
      handleNotificationAction(userInfo: userInfo)
    }

    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    completionHandler()
  }

  private func handleNotificationAction(userInfo: [AnyHashable: Any]) {
    // Extract notification data
    if let notificationType = userInfo["type"] as? String {
      // You can use Flutter method channel to communicate with Dart side
      if let controller = window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: "com.forcast.app/notifications", binaryMessenger: controller.binaryMessenger)
        channel.invokeMethod("handleNotificationTap", arguments: ["type": notificationType, "data": userInfo])
      }
    }
  }

  // MARK: - Background Processing

  override func application(
    _ application: UIApplication,
    performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    // Perform background tasks like syncing data
    print("Background fetch triggered")

    // You can communicate with Flutter side for background tasks
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "com.forcast.app/background", binaryMessenger: controller.binaryMessenger)
      channel.invokeMethod("performBackgroundFetch", arguments: nil) { result in
        if result != nil {
          completionHandler(.newData)
        } else {
          completionHandler(.noData)
        }
      }
    } else {
      completionHandler(.failed)
    }
  }

  // MARK: - URL Scheme Handling

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {

    // Handle deep links
    if url.scheme == "forcast" {
      handleDeepLink(url: url)
      return true
    }

    // Handle Google Sign In
    if url.scheme?.hasPrefix("com.googleusercontent.apps") == true {
      // This will be handled by Google Sign In plugin
      return super.application(app, open: url, options: options)
    }

    return super.application(app, open: url, options: options)
  }

  private func handleDeepLink(url: URL) {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "com.forcast.app/deeplink", binaryMessenger: controller.binaryMessenger)
      channel.invokeMethod("handleDeepLink", arguments: url.absoluteString)
    }
  }

  // MARK: - Apple Sign In State Monitoring

  private func setupAppleSignInStateMonitoring() {
    if #available(iOS 13.0, *) {
      // Check stored Apple user ID and monitor its state
      if let appleUserID = UserDefaults.standard.string(forKey: "appleUserID") {
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: appleUserID) { [weak self] (credentialState, error) in
          switch credentialState {
          case .authorized:
            print("🍎 Apple ID is authorized")
            // User is still authorized
            break
          case .revoked:
            print("🍎 Apple ID authorization has been revoked")
            // User has revoked authorization, sign them out
            DispatchQueue.main.async {
              self?.handleAppleSignInRevoked()
            }
          case .notFound:
            print("🍎 Apple ID not found")
            // User credential not found
            break
          default:
            break
          }
        }
      }
    }
  }

  private func handleAppleSignInRevoked() {
    // Clear stored Apple user data
    UserDefaults.standard.removeObject(forKey: "appleUserID")

    // Notify Flutter about the revocation
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "com.forcast.app/apple_signin", binaryMessenger: controller.binaryMessenger)
      channel.invokeMethod("credentialRevoked", arguments: nil)
    }

    print("🍎 Apple Sign In credentials cleared due to revocation")
  }

  // MARK: - App Lifecycle

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    // Clear badge count when app becomes active
    UIApplication.shared.applicationIconBadgeNumber = 0
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    // You can save important data here
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    super.applicationWillTerminate(application)
    // Save data before app terminates
  }
}
