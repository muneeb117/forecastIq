
import '../view/home/home_screen.dart';
import 'package:get/get.dart';
import '../view/splash/splash_screen.dart';

import '../view/settings/profile_screen.dart';
import '../bindings/app_bindings.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String home = '/home';
  static const String coinDetail = '/coin-detail';
  static const String profile = '/profile';

  // Route pages
  static List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      binding: AppBinding(),
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: profile,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
    ),
  ];

  // Navigation helpers
  static void toHome() => Get.offAllNamed(home);

  static void toCoinDetail({
    required String symbol,
    required String name,
    required String assetClass,
  }) {
    Get.toNamed(
      '$coinDetail?symbol=$symbol&name=$name&assetClass=$assetClass',
    );
  }

  static void toProfile() => Get.toNamed(profile);
}