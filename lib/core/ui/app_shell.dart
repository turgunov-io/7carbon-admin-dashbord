import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_route.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final selectedIndex = _selectedIndex(location);

    if (width < 900) {
      return Scaffold(
        appBar: AppBar(title: Text(AppRoutes.titleByLocation(location))),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                const ListTile(
                  title: Text(
                    'Carbon Admin',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: AppRoutes.navItems.length,
                    itemBuilder: (context, index) {
                      final item = AppRoutes.navItems[index];
                      return ListTile(
                        selected: selectedIndex == index,
                        leading: Icon(item.icon),
                        title: Text(item.title),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go(item.path);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: child,
      );
    }

    final railExtended = width > 1320;
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
              extended: railExtended,
              onDestinationSelected: (index) {
                context.go(AppRoutes.navItems[index].path);
              },
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  railExtended ? 'Carbon Admin' : 'CA',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              destinations: AppRoutes.navItems
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.title),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _selectedIndex(String currentLocation) {
    for (var i = 0; i < AppRoutes.navItems.length; i++) {
      if (currentLocation.startsWith(AppRoutes.navItems[i].path)) {
        return i;
      }
    }
    return 0;
  }
}
