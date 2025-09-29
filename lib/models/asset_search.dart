class AssetSearch {
  final String symbol;
  final String name;
  final String assetClass;
  final bool hasForecasts;

  AssetSearch({
    required this.symbol,
    required this.name,
    required this.assetClass,
    required this.hasForecasts,
  });

  factory AssetSearch.fromJson(Map<String, dynamic> json) {
    return AssetSearch(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      assetClass: json['asset_class'] ?? '',
      hasForecasts: json['has_forecasts'] ?? false,
    );
  }
}
