import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../controllers/forecast_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/controller_manager.dart';
import '../controllers/trend_controller.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../services/notification_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Core services - Initialize first
    Get.put<FavoritesService>(FavoritesService.instance, permanent: true);


    Get.put(AuthService(), permanent: true);
    Get.put(ForecastController(), permanent: true);
    Get.put(TrendController(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(AppController(), permanent: true);
    Get.put(FavoritesController(), permanent: true);
    Get.put(ControllerManager(), permanent: true);

  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForecastController>(() => ForecastController());
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

class TrendBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrendController>(() => TrendController());
  }
}

class CoinDetailBinding extends Bindings {
  @override
  void dependencies() {
    // CoinDetailController is created with parameters, so we'll handle it differently
    // Get.lazyPut<CoinDetailController>(() => CoinDetailController());
  }
}

class ForecastBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForecastController>(
          () => ForecastController(),
    );
  }
}