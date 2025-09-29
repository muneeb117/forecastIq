import 'package:get/get.dart';
import 'coin_detail_controller.dart';

class ControllerManager extends GetxController {
  static ControllerManager get instance => Get.find();

  // Track active coin detail controllers
  final Set<String> _activeCoinControllers = <String>{};
  static const int maxControllers = 10; // Limit number of cached controllers

  // Register a coin detail controller
  void registerCoinController(String symbol) {
    _activeCoinControllers.add(symbol);
    _cleanupOldControllers();
  }

  // Clean up old controllers when limit exceeded
  void _cleanupOldControllers() {
    if (_activeCoinControllers.length > maxControllers) {
      // Remove oldest controllers (simple FIFO cleanup)
      final controllersToRemove = _activeCoinControllers.length - maxControllers;
      final symbolsToRemove = _activeCoinControllers.take(controllersToRemove).toList();

      for (final symbol in symbolsToRemove) {
        try {
          Get.delete<CoinDetailController>(tag: symbol);
          _activeCoinControllers.remove(symbol);
          print('🗑️ Cleaned up controller for $symbol');
        } catch (e) {
          print('❌ Failed to cleanup controller for $symbol: $e');
        }
      }
    }
  }

  // Manual cleanup for specific symbol
  void cleanupCoinController(String symbol) {
    try {
      Get.delete<CoinDetailController>(tag: symbol);
      _activeCoinControllers.remove(symbol);
      print('🗑️ Manually cleaned up controller for $symbol');
    } catch (e) {
      print('❌ Failed to manually cleanup controller for $symbol: $e');
    }
  }

  // Cleanup all coin controllers
  void cleanupAllCoinControllers() {
    for (final symbol in _activeCoinControllers.toList()) {
      cleanupCoinController(symbol);
    }
  }

  // Check if controller exists for symbol
  bool hasControllerFor(String symbol) {
    return Get.isRegistered<CoinDetailController>(tag: symbol);
  }

  // Get active controller count
  int get activeControllerCount => _activeCoinControllers.length;

  @override
  void onClose() {
    cleanupAllCoinControllers();
    super.onClose();
  }
}