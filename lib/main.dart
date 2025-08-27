import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forcast/view/Help_FAQ_Screen.dart';
import 'package:forcast/view/Term_and_condition_screen.dart';
import 'package:forcast/view/about_app.dart';
import 'package:forcast/view/favourite_screen.dart';
import 'package:forcast/view/notifications_settings_screen.dart';
import 'package:forcast/view/privacy_policy_screen.dart';
import 'package:forcast/view/profile_screen.dart';
import 'package:forcast/view/security_screen.dart';
import 'package:forcast/view/setting_screen.dart';
import 'package:forcast/view/splash_screen.dart';
import '../core/constants/colors.dart';
import '../widgets/dismiss_keyboard.dart';
import 'package:get/get.dart';
void main() {

//  SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     systemNavigationBarDividerColor: AppColors.kscoffald,
  //     systemNavigationBarColor: AppColors.kscoffald,
  //     statusBarColor: AppColors.kscoffald,
  //     statusBarBrightness: Brightness.light,
  //     systemStatusBarContrastEnforced: true,
  //     statusBarIconBrightness: Brightness.light,
  //     systemNavigationBarIconBrightness: Brightness.light,
  //   ),
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return DismissKeyboardOnTap(
      child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
        return GetMaterialApp(
        title: 'Flutter Demo',

        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          fontFamily: "SfProDisplay",
          primaryColor: AppColors.kprimary,
          scaffoldBackgroundColor: AppColors.kscoffald,

        ),
        home: SplashScreen()

      );
        }
      ),
    );
}
}
