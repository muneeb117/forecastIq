import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forcast/view/splash_screen.dart';
import '../core/constants/colors.dart';
import '../widgets/dismiss_keyboard.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  Get.put(AuthService());

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
