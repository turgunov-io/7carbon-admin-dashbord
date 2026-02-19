import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_route.dart';
import '../theme/app_colors.dart';
import '../theme/theme_mode_provider.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final selectedIndex = _selectedIndex(location);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    if (width < 960) {
      return Scaffold(
        appBar: AppBar(title: Text(AppRoutes.titleByLocation(location))),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: _ThemeToggleButton(
          isDark: isDark,
          onTap: () => _toggleTheme(ref, isDark),
        ),
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
                      final itemEnabled = item.enabled;
                      return ListTile(
                        selected: selectedIndex == index,
                        enabled: itemEnabled,
                        leading: Icon(item.icon),
                        title: Text(item.title),
                        subtitle: itemEnabled || item.disabledHint == null
                            ? null
                            : Text(item.disabledHint!),
                        onTap: () {
                          Navigator.of(context).pop();
                          _onNavTap(context, item);
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

    final railExtended = width >= 1360;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _ThemeToggleButton(
        isDark: isDark,
        onTap: () => _toggleTheme(ref, isDark),
      ),
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: selectedIndex,
              extended: railExtended,
              onDestinationSelected: (index) {
                _onNavTap(context, AppRoutes.navItems[index]);
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
                      icon: Icon(
                        item.icon,
                        color: item.enabled
                            ? null
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
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

  void _onNavTap(BuildContext context, AppNavItem item) {
    if (!item.enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(item.disabledHint ?? 'Раздел временно недоступен'),
        ),
      );
      return;
    }
    context.go(item.path);
  }

  void _toggleTheme(WidgetRef ref, bool isDark) {
    ref.read(themeModeProvider.notifier).state = isDark
        ? ThemeMode.light
        : ThemeMode.dark;
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.isDark, required this.onTap});

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'theme_toggle_fab',
      onPressed: onTap,
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      label: Text(isDark ? 'Светлая тема' : 'Темная тема'),
      backgroundColor: isDark ? AppColors.surfaceDarker : AppColors.white,
      foregroundColor: isDark ? AppColors.white : AppColors.black,
    );
  }
}
