import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/domain/admin_entity_registry.dart';
import '../../features/admin/ui/admin_entity_page.dart';
import '../../features/dashboard/ui/dashboard_page.dart';
import '../../features/storage/ui/storage_page.dart';
import '../ui/app_shell.dart';
import 'app_route.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => AppRoutes.dashboard),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.storage,
            redirect: (context, state) {
              if (AppRoutes.storageEnabled) {
                return null;
              }
              return AppRoutes.dashboard;
            },
            builder: (context, state) => const StoragePage(),
          ),
          GoRoute(
            path: '${AppRoutes.entitiesPrefix}/:entityKey',
            builder: (context, state) {
              final entityKey = state.pathParameters['entityKey'] ?? '';
              if (!adminEntityMap.containsKey(entityKey)) {
                return const _NotFoundPage();
              }

              return AdminEntityPage(
                entityKey: entityKey,
                openCreateOnLoad: state.uri.queryParameters['create'] == '1',
              );
            },
          ),
        ],
      ),
    ],
  );
});

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Раздел не найден'));
  }
}
