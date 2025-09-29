import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class TradingAIService {
  static const String baseUrl = 'https://trading-production-85d8.up.railway.app';

  static const List<String> cryptoAssets = ['BTC', 'ETH', 'USDT', 'XRP', 'BNB', 'SOL', 'USDC', 'DOGE', 'ADA', 'TRX'];
  static const List<String> stockAssets = ['NVDA', 'MSFT', 'AAPL', 'GOOGL', 'AMZN', 'META', 'AVGO', 'TSLA', 'BRK-B', 'JPM'];
  static const List<String> macroAssets = ['GDP', 'CPI', 'UNEMPLOYMENT', 'FED_RATE', 'CONSUMER_CONFIDENCE'];

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<MarketSummary>> getMarketSummary({String? assetClass, int limit = 10}) async {
    try {
      String url = '$baseUrl/api/market/summary?limit=$limit';
      if (assetClass != null) {
        url += '&class=$assetClass';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> && responseData.containsKey('assets')) {
          final List<dynamic> assets = responseData['assets'] as List<dynamic>;
          return assets.map((item) {
            if (item is Map<String, dynamic>) {
              return MarketSummary.fromJson(item);
            } else {
              //print('Warning: Expected Map but got ${item.runtimeType}');
              return null;
            }
          }).where((item) => item != null).cast<MarketSummary>().toList();
        } else if (responseData is List) {
          return responseData.map((item) {
            if (item is Map<String, dynamic>) {
              return MarketSummary.fromJson(item);
            } else {
              //print('Warning: Expected Map but got ${item.runtimeType}');
              return null;
            }
          }).where((item) => item != null).cast<MarketSummary>().toList();
        } else {
          //print('Unexpected response format: ${responseData.runtimeType}');
          return [];
        }
      } else {
        //print('HTTP Error: ${response.statusCode}');
        //print('Response body: ${response.body}');
      }
      return [];
    } catch (e, stackTrace) {
      //print('Error fetching market summary: $e');
      //print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<AssetForecast?> getAssetForecast(String symbol, {String timeframe = '1D'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/asset/$symbol/forecast?timeframe=$timeframe')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AssetForecast.fromJson(data);
      }
      return null;
    } catch (e) {
      //print('Error fetching asset forecast: $e');
      return null;
    }
  }

  Future<AssetTrends?> getAssetTrends(String symbol, {String timeframe = '7D'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/asset/$symbol/trends?timeframe=$timeframe')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AssetTrends.fromJson(data);
      }
      return null;
    } catch (e) {
      //print('Error fetching asset trends: $e');
      return null;
    }
  }

  Future<List<AssetSearch>> searchAssets(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/assets/search?query=$query')
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => AssetSearch.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      //print('Error searching assets: $e');
      return [];
    }
  }

  Future<List<AssetForecast>> getAllCryptoForecasts() async {
    List<AssetForecast> forecasts = [];
    for (String symbol in cryptoAssets) {
      final forecast = await getAssetForecast(symbol);
      if (forecast != null) {
        forecasts.add(forecast);
      }
    }
    return forecasts;
  }

  Future<List<AssetForecast>> getAllStockForecasts() async {
    List<AssetForecast> forecasts = [];
    for (String symbol in stockAssets) {
      final forecast = await getAssetForecast(symbol);
      if (forecast != null) {
        forecasts.add(forecast);
      }
    }
    return forecasts;
  }

  Future<List<AssetForecast>> getAllMacroForecasts() async {
    List<AssetForecast> forecasts = [];
    for (String symbol in macroAssets) {
      final forecast = await getAssetForecast(symbol);
      if (forecast != null) {
        forecasts.add(forecast);
      }
    }
    return forecasts;
  }
}