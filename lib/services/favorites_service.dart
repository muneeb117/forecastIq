import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteItem {
  final String symbol;
  final String name;
  final String? image;
  final String type; // 'crypto', 'stock', 'macro'
  final DateTime addedAt;

  FavoriteItem({
    required this.symbol,
    required this.name,
    this.image,
    required this.type,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'image': image,
      'type': type,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      type: json['type'] ?? 'crypto',
      addedAt: DateTime.tryParse(json['addedAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItem &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol;

  @override
  int get hashCode => symbol.hashCode;
}

class FavoritesService {
  static const String _favoritesKey = 'user_favorites';
  static FavoritesService? _instance;
  SharedPreferences? _prefs;

  List<FavoriteItem> _favorites = [];
  List<Function(List<FavoriteItem>)> _listeners = [];

  FavoritesService._();

  static FavoritesService get instance {
    _instance ??= FavoritesService._();
    return _instance!;
  }

  // Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFavorites();
  }

  // Load favorites from storage
  Future<void> _loadFavorites() async {
    try {
      final favoritesJson = _prefs?.getString(_favoritesKey);
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = json.decode(favoritesJson);
        _favorites = favoritesList
            .map((item) => FavoriteItem.fromJson(item))
            .toList();
        _notifyListeners();
      }
    } catch (e) {
      print('Error loading favorites: $e');
      _favorites = [];
    }
  }

  // Save favorites to storage
  Future<void> _saveFavorites() async {
    try {
      final favoritesJson = json.encode(_favorites.map((item) => item.toJson()).toList());
      await _prefs?.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  // Add item to favorites
  Future<void> addToFavorites({
    required String symbol,
    required String name,
    String? image,
    required String type,
  }) async {
    final newFavorite = FavoriteItem(
      symbol: symbol,
      name: name,
      image: image,
      type: type,
      addedAt: DateTime.now(),
    );

    if (!_favorites.contains(newFavorite)) {
      _favorites.add(newFavorite);
      await _saveFavorites();
      _notifyListeners();
    }
  }

  // Remove item from favorites
  Future<void> removeFromFavorites(String symbol) async {
    _favorites.removeWhere((item) => item.symbol == symbol);
    await _saveFavorites();
    _notifyListeners();
  }

  // Toggle favorite status
  Future<void> toggleFavorite({
    required String symbol,
    required String name,
    String? image,
    required String type,
  }) async {
    if (isFavorite(symbol)) {
      await removeFromFavorites(symbol);
    } else {
      await addToFavorites(
        symbol: symbol,
        name: name,
        image: image,
        type: type,
      );
    }
  }

  // Check if item is favorite
  bool isFavorite(String symbol) {
    return _favorites.any((item) => item.symbol == symbol);
  }

  // Get all favorites
  List<FavoriteItem> get favorites => List.unmodifiable(_favorites);

  // Get favorites by type
  List<FavoriteItem> getFavoritesByType(String type) {
    return _favorites.where((item) => item.type == type).toList();
  }

  // Get crypto favorites
  List<FavoriteItem> get cryptoFavorites => getFavoritesByType('crypto');

  // Get stock favorites
  List<FavoriteItem> get stockFavorites => getFavoritesByType('stock');

  // Get macro favorites
  List<FavoriteItem> get macroFavorites => getFavoritesByType('macro');

  // Add listener for favorites changes
  void addListener(Function(List<FavoriteItem>) listener) {
    _listeners.add(listener);
  }

  // Remove listener
  void removeListener(Function(List<FavoriteItem>) listener) {
    _listeners.remove(listener);
  }

  // Clear all listeners (useful for debugging)
  void clearAllListeners() {
    _listeners.clear();
  }

  // Notify all listeners
  void _notifyListeners() {
    // Create a copy of listeners to avoid concurrent modification
    final listenersCopy = List<Function(List<FavoriteItem>)>.from(_listeners);

    for (var listener in listenersCopy) {
      try {
        listener(_favorites);
      } catch (e) {
        // Remove invalid listeners
        print('Removing invalid listener: $e');
        _listeners.remove(listener);
      }
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    _favorites.clear();
    await _saveFavorites();
    _notifyListeners();
  }

  // Get total count
  int get totalCount => _favorites.length;

  // Get count by type
  int getCountByType(String type) => getFavoritesByType(type).length;

  // Determine item type based on symbol
  static String determineItemType(String symbol) {
    // Common crypto symbols
    const cryptoSymbols = ['BTC', 'ETH', 'ADA', 'DOT', 'SOL', 'AVAX', 'MATIC', 'LINK', 'UNI', 'AAVE'];

    // Common stock symbols
    const stockSymbols = ['AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA', 'NVDA', 'META', 'NFLX', 'CRM', 'ORCL'];

    // Common macro symbols
    const macroSymbols = ['GDP', 'CPI', 'DXY', 'TNX', 'VIX', 'GC=F', 'CL=F', 'NG=F', 'SI=F', 'PL=F'];

    if (cryptoSymbols.contains(symbol)) {
      return 'crypto';
    } else if (stockSymbols.contains(symbol)) {
      return 'stock';
    } else if (macroSymbols.contains(symbol)) {
      return 'macro';
    } else {
      // Default to crypto if unknown
      return 'crypto';
    }
  }
}