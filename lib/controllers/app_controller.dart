import 'package:get/get.dart';
import '../core/helpers/message_helper.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../services/websocket_service.dart';

class AppController extends GetxController {
  static AppController get instance => Get.find();

  // Services
  late AuthService authService;
  late FavoritesService favoritesService;
  late WebSocketService webSocketService;

  // Global state
  final RxBool isLoading = false.obs;
  final RxString currentTheme = 'dark'.obs;
  final RxBool isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _listenToConnectivity();
  }

  void _initializeServices() {
    authService = AuthService.instance;
    favoritesService = FavoritesService.instance;
    webSocketService = WebSocketManager().getConnection('shared');
  }

  void _listenToConnectivity() {
    // Monitor WebSocket connection status
    ever(webSocketService.isConnected.obs, (bool connected) {
      isConnected.value = connected;
      if (!connected) {
        MessageHelper.showWarning(
          'Trying to reconnect...',
          title: 'Connection Lost',
        );
      }
    });
  }

  // Global loading state management
  void setLoading(bool loading) {
    isLoading.value = loading;
  }

  // Theme management
  void toggleTheme() {
    currentTheme.value = currentTheme.value == 'dark' ? 'light' : 'dark';
  }

  // User session management
  bool get isLoggedIn => authService.isSignedIn;
  String? get userName => authService.userName;
  String? get userEmail => authService.userEmail;
  String? get userProfileImage => authService.userProfileImage;

  // Global sign out
  Future<void> signOut() async {
    setLoading(true);
    await authService.signOut();
    await favoritesService.clearAllFavorites();
    webSocketService.disconnect();
    setLoading(false);
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    webSocketService.disconnect();
    super.onClose();
  }
}