class ChartTrendData {
  final List<double> actual;
  final List<double> predicted;
  final List<String> timestamps;

  ChartTrendData({
    required this.actual,
    required this.predicted,
    required this.timestamps,
  });

  factory ChartTrendData.fromJson(Map<String, dynamic> json) {
    return ChartTrendData(
      actual: (json['actual'] as List?)
          ?.map((item) => (item as num).toDouble())
          .toList() ?? [],
      predicted: (json['predicted'] as List?)
          ?.map((item) => (item as num).toDouble())
          .toList() ?? [],
      timestamps: (json['timestamps'] as List?)
          ?.map((item) => item.toString())
          .toList() ?? [],
    );
  }

  // Get min and max values for chart scaling
  double get minPrice {
    final allPrices = [...actual, ...predicted];
    return allPrices.isEmpty ? 0 : allPrices.reduce((a, b) => a < b ? a : b);
  }

  double get maxPrice {
    final allPrices = [...actual, ...predicted];
    return allPrices.isEmpty ? 0 : allPrices.reduce((a, b) => a > b ? a : b);
  }

  // Get chart spots for FL Chart
  List<Map<String, dynamic>> get chartSpots {
    List<Map<String, dynamic>> spots = [];

    for (int i = 0; i < actual.length && i < timestamps.length; i++) {
      spots.add({
        'x': i.toDouble(),
        'actual': actual[i],
        'predicted': i < predicted.length ? predicted[i] : null,
        'timestamp': timestamps[i],
      });
    }

    return spots;
  }
}
