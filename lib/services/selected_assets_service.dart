import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SelectedAssetsService extends GetxController {
  static const String _storageKey = 'selected_assets';

  final RxList<AssetData> _selectedAssets = <AssetData>[].obs;

  List<AssetData> get selectedAssets => _selectedAssets;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedAssets();
  }

  Future<void> _loadSelectedAssets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedAssets = prefs.getString(_storageKey);

      if (savedAssets != null) {
        final List<dynamic> jsonList = json.decode(savedAssets);
        _selectedAssets.value = jsonList
            .map((json) => AssetData.fromJson(json))
            .toList();
      }
    } catch (e) {
      //print('Error loading selected assets: $e');
    }
  }

  Future<void> _saveSelectedAssets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(
        _selectedAssets.map((asset) => asset.toJson()).toList()
      );
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      //print('Error saving selected assets: $e');
    }
  }

  void addAsset(AssetData asset) {
    if (!_selectedAssets.contains(asset)) {
      _selectedAssets.add(asset);
      _saveSelectedAssets();
    }
  }

  void removeAsset(AssetData asset) {
    _selectedAssets.remove(asset);
    _saveSelectedAssets();
  }

  bool isAssetSelected(AssetData asset) {
    return _selectedAssets.contains(asset);
  }

  void clearAllAssets() {
    _selectedAssets.clear();
    _saveSelectedAssets();
  }

  bool get hasSelectedAssets => _selectedAssets.isNotEmpty;
  int get selectedAssetsCount => _selectedAssets.length;
}

class AssetData {
  final String symbol;
  final String name;
  final String category;
  final String type;

  AssetData(this.symbol, this.name, this.category, this.type);

  @override
  bool operator ==(Object other) {
    return other is AssetData && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'category': category,
      'type': type,
    };
  }

  factory AssetData.fromJson(Map<String, dynamic> json) {
    return AssetData(
      json['symbol'] ?? '',
      json['name'] ?? '',
      json['category'] ?? '',
      json['type'] ?? '',
    );
  }
}