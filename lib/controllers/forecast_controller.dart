import 'package:get/get.dart';
import '../models/models.dart';
import './asset_list_controller.dart';

class ForecastController extends AssetListController {
  final RxString searchQuery = ''.obs;

  void updateSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
  }

  List<MarketSummary> getFilteredForecasts(List<MarketSummary> forecasts) {
    if (searchQuery.value.isEmpty) return forecasts;
    return forecasts.where((forecast) {
      return forecast.symbol.toLowerCase().contains(searchQuery.value) ||
             forecast.name.toLowerCase().contains(searchQuery.value);
    }).toList();
  }

}
