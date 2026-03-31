class DashboardStatsModel {
  final int totalOrders;
  final double totalRevenue;
  final int mealsLeft;
  final Map<String, MealStat> todayStats;

  DashboardStatsModel({
    required this.totalOrders,
    required this.totalRevenue,
    required this.mealsLeft,
    required this.todayStats,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> todayJson = json['todayStats'] ?? {};
    final Map<String, MealStat> stats = {};
    
    todayJson.forEach((key, value) {
      stats[key] = MealStat.fromJson(value);
    });

    return DashboardStatsModel(
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      mealsLeft: json['mealsLeft'] ?? 0,
      todayStats: stats,
    );
  }
}

class MealStat {
  final int orders;
  final int pending;

  MealStat({required this.orders, required this.pending});

  factory MealStat.fromJson(Map<String, dynamic> json) {
    return MealStat(
      orders: json['orders'] ?? 0,
      pending: json['pending'] ?? 0,
    );
  }
}
