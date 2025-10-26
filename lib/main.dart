import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'view/splash/splash_screen.dart';
import '../core/constants/colors.dart';
import '../widgets/dismiss_keyboard.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';

import 'bindings/app_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );


   SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarColor: AppColors.ksecondary,
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarBrightness: Brightness.dark, // iOS: dark = white icons
      statusBarIconBrightness: Brightness.light, // Android: light = white icons
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Also set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
            title: 'ForcastIQ',
            debugShowCheckedModeBanner: false,
            initialBinding: AppBinding(),
            theme: ThemeData(
              fontFamily: "SfProDisplay",
              primaryColor: AppColors.kprimary,
              scaffoldBackgroundColor: AppColors.kscoffald,
              appBarTheme: AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarBrightness: Brightness.dark, // iOS: white icons
                  statusBarIconBrightness: Brightness.light, // Android: white icons
                  systemNavigationBarColor: AppColors.ksecondary,
                  systemNavigationBarIconBrightness: Brightness.light,
                ),
              ),
            ),
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
