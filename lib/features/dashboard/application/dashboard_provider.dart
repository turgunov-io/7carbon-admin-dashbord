import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin/application/admin_providers.dart';
import '../../admin/domain/admin_entity_registry.dart';
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
