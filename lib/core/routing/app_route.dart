import 'package:flutter/material.dart';

import '../../features/admin/domain/admin_entity_registry.dart';

class AppNavItem {
  const AppNavItem({
    required this.title,
    required this.path,
    required this.icon,
    this.entityKey,
  });

  final String title;
  final String path;
  final IconData icon;
  final String? entityKey;
}

class AppRoutes {
  const AppRoutes._();

  static const dashboard = '/dashboard';
  static const entitiesPrefix = '/entities';

  static String entity(String key) => '$entitiesPrefix/$key';
  static String createEntity(String key) => '${entity(key)}?create=1';

  static final navItems = <AppNavItem>[
    const AppNavItem(
      title: 'Дашборд',
      path: dashboard,
      icon: Icons.dashboard_outlined,
    ),
    ...adminEntities.map(
      (entity) => AppNavItem(
        title: entity.title,
        path: AppRoutes.entity(entity.key),
        icon: entity.icon,
        entityKey: entity.key,
      ),
    ),
  ];

  static String titleByLocation(String location) {
    for (final item in navItems) {
      if (location.startsWith(item.path)) {
        return item.title;
      }
    }
    return 'Admin Dashboard';
  }
}
