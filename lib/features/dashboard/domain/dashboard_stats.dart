import 'health_status.dart';

class DashboardStats {
  const DashboardStats({
    required this.health,
    required this.banners,
    required this.contacts,
    required this.aboutMetrics,
    required this.aboutSections,
    required this.partners,
    required this.tuning,
    required this.serviceOfferings,
    required this.privacySections,
    required this.portfolioItems,
    required this.workPosts,
    required this.consultationsNew,
    required this.consultationsInProgress,
    required this.consultationsCompleted,
  });

  final HealthStatus health;
  final int banners;
  final int contacts;
  final int aboutMetrics;
  final int aboutSections;
  final int partners;
  final int tuning;
  final int serviceOfferings;
  final int privacySections;
  final int portfolioItems;
  final int workPosts;
  final int consultationsNew;
  final int consultationsInProgress;
  final int consultationsCompleted;

  int get consultationsTotal =>
      consultationsNew + consultationsInProgress + consultationsCompleted;
}
