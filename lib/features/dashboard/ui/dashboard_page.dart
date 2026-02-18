import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_route.dart';
import '../../../core/ui/widgets/state_views.dart';
import '../../admin/domain/admin_entity_registry.dart';
import '../application/dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(dashboardCountsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Сводка количества записей и быстрые действия',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.createEntity('banners')),
                icon: const Icon(Icons.add),
                label: const Text('Create banner'),
              ),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.createEntity('partners')),
                icon: const Icon(Icons.add),
                label: const Text('Create partner'),
              ),
              FilledButton.icon(
                onPressed: () =>
                    context.go(AppRoutes.createEntity('service_offerings')),
                icon: const Icon(Icons.add),
                label: const Text('Create service offering'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: countsAsync.when(
              data: (counts) {
                if (counts.counts.isEmpty) {
                  return const EmptyState(message: 'Нет данных');
                }

                return GridView.builder(
                  itemCount: adminEntities.length + 1,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.9,
                  ),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _CountCard(
                        title: 'Всего записей',
                        value: counts.total,
                        icon: Icons.summarize_outlined,
                        onTap: null,
                      );
                    }

                    final entity = adminEntities[index - 1];
                    return _CountCard(
                      title: entity.title,
                      value: counts.countFor(entity.key),
                      icon: entity.icon,
                      onTap: () => context.go(AppRoutes.entity(entity.key)),
                    );
                  },
                );
              },
              loading: () => const LoadingState(),
              error: (error, _) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(dashboardCountsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String title;
  final int value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22),
            const Spacer(),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: content,
    );
  }
}
