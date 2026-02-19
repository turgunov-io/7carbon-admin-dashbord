import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin/application/admin_providers.dart';
import '../../admin/domain/admin_entity_registry.dart';
import '../domain/consultation_trend.dart';
import '../domain/dashboard_counts.dart';

final dashboardCountsProvider = FutureProvider<DashboardCounts>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);

  final entries = await Future.wait(
    adminEntities.map((entity) async {
      var count = 0;
      try {
        count = await repository.fetchCount(entity);
      } catch (_) {
        count = 0;
      }
      return MapEntry(entity.key, count);
    }),
  );

  return DashboardCounts(
    counts: {for (final entry in entries) entry.key: entry.value},
  );
});

final dashboardConsultationTrendProvider =
    FutureProvider<DashboardConsultationTrend>((ref) async {
      final repository = ref.watch(adminRepositoryProvider);
      final consultationsEntity = adminEntityMap['consultations'];
      if (consultationsEntity == null) {
        return const DashboardConsultationTrend(
          monthlyPoints: <DashboardMonthlyPoint>[],
          currentMonthCount: 0,
          previousMonthCount: 0,
        );
      }

      final rows = await repository.fetchList(consultationsEntity);
      final nowUtc = DateTime.now().toUtc();
      final currentMonthUtc = DateTime.utc(nowUtc.year, nowUtc.month);
      const visibleMonths = 12;

      final monthStarts = List.generate(visibleMonths, (index) {
        final offset = visibleMonths - 1 - index;
        return DateTime.utc(
          currentMonthUtc.year,
          currentMonthUtc.month - offset,
        );
      });

      final counters = <String, int>{
        for (final monthStart in monthStarts) _monthKey(monthStart): 0,
      };

      for (final row in rows) {
        final createdAt = _parseDate(row.values['created_at']);
        if (createdAt == null) {
          continue;
        }

        final monthStart = DateTime.utc(createdAt.year, createdAt.month);
        final key = _monthKey(monthStart);
        if (counters.containsKey(key)) {
          counters[key] = (counters[key] ?? 0) + 1;
        }
      }

      final points = monthStarts
          .map(
            (monthStart) => DashboardMonthlyPoint(
              monthStartUtc: monthStart,
              count: counters[_monthKey(monthStart)] ?? 0,
            ),
          )
          .toList(growable: false);

      final previousMonthUtc = DateTime.utc(
        currentMonthUtc.year,
        currentMonthUtc.month - 1,
      );

      return DashboardConsultationTrend(
        monthlyPoints: points,
        currentMonthCount: counters[_monthKey(currentMonthUtc)] ?? 0,
        previousMonthCount: counters[_monthKey(previousMonthUtc)] ?? 0,
      );
    });

String _monthKey(DateTime monthStartUtc) {
  return '${monthStartUtc.year}-${monthStartUtc.month.toString().padLeft(2, '0')}';
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value.toUtc();
  }
  final text = value.toString().trim();
  if (text.isEmpty) {
    return null;
  }
  return DateTime.tryParse(text)?.toUtc();
}
