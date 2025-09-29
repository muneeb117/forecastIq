class ChartData {
  final List<double> pastPrices;
  final List<double> futurePrices;
  final List<String> timestamps;
  final int pastDataPoints;
  final int futureDataPoints;

  ChartData({
    required this.pastPrices,
    required this.futurePrices,
    required this.timestamps,
    required this.pastDataPoints,
    required this.futureDataPoints,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    final past = (json['past'] as List? ?? []).map((e) => (e as num).toDouble()).toList();
    final future = (json['future'] as List? ?? []).map((e) => (e as num).toDouble()).toList();
    return ChartData(
      pastPrices: past,
      futurePrices: future,
      timestamps: (json['timestamps'] as List? ?? []).map((e) => e.toString()).toList(),
      pastDataPoints: past.length,
      futureDataPoints: future.length,
    );
  }
}
