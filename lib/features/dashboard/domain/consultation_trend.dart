class DashboardConsultationTrend {
  const DashboardConsultationTrend({
    required this.monthlyPoints,
    required this.currentMonthCount,
    required this.previousMonthCount,
  });

  final List<DashboardMonthlyPoint> monthlyPoints;
  final int currentMonthCount;
  final int previousMonthCount;

  int get delta => currentMonthCount - previousMonthCount;
}

class DashboardMonthlyPoint {
  const DashboardMonthlyPoint({
    required this.monthStartUtc,
    required this.count,
  });

  final DateTime monthStartUtc;
  final int count;
}
