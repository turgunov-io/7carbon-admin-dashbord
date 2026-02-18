class DashboardCounts {
  const DashboardCounts({required this.counts});

  final Map<String, int> counts;

  int countFor(String key) => counts[key] ?? 0;

  int get total => counts.values.fold<int>(0, (sum, value) => sum + value);
}
