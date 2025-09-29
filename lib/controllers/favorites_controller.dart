import 'package:get/get.dart';
import '../core/helpers/message_helper.dart';
import '../services/favorites_service.dart';



class FavoritesController extends GetxController {
  // Service
  final FavoritesService _favoritesService = FavoritesService.instance;

  // Observable state
  final RxList<FavoriteItem> favorites = <FavoriteItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, bool> favoriteStatus = <String, bool>{}.obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxString searchQuery = ''.obs;

  // Tab names
  final List<String> tabs = ['All', 'Stocks', 'Crypto', 'Macro'];

  @override
  void onInit() {
    super.onInit();
    _initializeFavorites();
  }

  Future<void> _initializeFavorites() async {
    isLoading.value = true;
    await _favoritesService.init();
    _loadFavorites();
    _favoritesService.addListener(_onFavoritesChanged);
    isLoading.value = false;
  }

  void _loadFavorites() {
    favorites.value = _favoritesService.favorites;
    _updateFavoriteStatus();
  }

  void _onFavoritesChanged(List<FavoriteItem> updatedFavorites) {
    favorites.value = updatedFavorites;
    _updateFavoriteStatus();
  }

  void _updateFavoriteStatus() {
    favoriteStatus.clear();
    for (var favorite in favorites) {
      favoriteStatus[favorite.symbol] = true;
    }
  }

  // Check if asset is favorite
  bool isFavorite(String symbol) {
    return favoriteStatus[symbol] ?? false;
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String symbol, String name, String assetClass) async {
    try {
      if (isFavorite(symbol)) {
        await removeFavorite(symbol);
      } else {
        await addFavorite(symbol, name, assetClass);
      }
    } catch (e) {
      MessageHelper.showError(
        'Failed to update favorites: ${e.toString()}',
      );
    }
  }

  // Add to favorites
  Future<void> addFavorite(String symbol, String name, String assetClass) async {
    try {
      await _favoritesService.addToFavorites(
        symbol: symbol,
        name: name,
        type: assetClass,
      );
      favoriteStatus[symbol] = true;

      MessageHelper.showSuccess(
        '$symbol has been added to your favorites',
        title: 'Added to Favorites',
      );
    } catch (e) {
      MessageHelper.showError(
        'Failed to add to favorites: ${e.toString()}',
      );
    }
  }

  // Remove from favorites
  Future<void> removeFavorite(String symbol) async {
    try {
      await _favoritesService.removeFromFavorites(symbol);
      favoriteStatus[symbol] = false;

      MessageHelper.showInfo(
        '$symbol has been removed from your favorites',
        title: 'Removed from Favorites',
      );
    } catch (e) {
      MessageHelper.showError(
        'Failed to remove from favorites: ${e.toString()}',
      );
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      Get.defaultDialog(
        title: 'Clear All Favorites',
        middleText: 'Are you sure you want to remove all favorites?',
        textConfirm: 'Yes',
        textCancel: 'No',
        onConfirm: () async {
          await _favoritesService.clearAllFavorites();
          favoriteStatus.clear();
          Get.back();

          MessageHelper.showSuccess(
            'All favorites have been removed',
            title: 'Favorites Cleared',
          );
        },
      );
    } catch (e) {
      MessageHelper.showError(
        'Failed to clear favorites: ${e.toString()}',
      );
    }
  }

  // Get favorites by asset class
  List<FavoriteItem> getFavoritesByClass(String assetClass) {
    return favorites.where((fav) => fav.type == assetClass).toList();
  }

  // Get favorite symbols for easy checking
  Set<String> get favoriteSymbols {
    return favorites.map((fav) => fav.symbol).toSet();
  }

  // Get favorites count
  int get favoritesCount => favorites.length;

  // Check if has favorites
  bool get hasFavorites => favorites.isNotEmpty;

  // Tab management
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  // Search functionality
  void updateSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
  }

  // Filter favorites based on search query
  List<FavoriteItem> filterFavorites(List<FavoriteItem> items) {
    if (searchQuery.value.isEmpty) return items;

    return items.where((item) {
      return item.symbol.toLowerCase().contains(searchQuery.value) ||
          item.name.toLowerCase().contains(searchQuery.value);
    }).toList();
  }

  // Get filtered favorites by tab
  List<FavoriteItem> get filteredFavorites {
    List<FavoriteItem> tabFavorites;

    switch (selectedTabIndex.value) {
      case 0: // All
        tabFavorites = favorites;
        break;
      case 1: // Stocks
        tabFavorites = _favoritesService.stockFavorites;
        break;
      case 2: // Crypto
        tabFavorites = _favoritesService.cryptoFavorites;
        break;
      case 3: // Macro
        tabFavorites = _favoritesService.macroFavorites;
        break;
      default:
        tabFavorites = favorites;
    }

    return filterFavorites(tabFavorites);
  }


  @override
  void onClose() {
    _favoritesService.removeListener(_onFavoritesChanged);
    super.onClose();
  }
}