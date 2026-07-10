import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';

class NavDestination {
  const NavDestination({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;
}

const _mainDestinations = <NavDestination>[
  NavDestination(path: '/', label: 'Tableau de bord', icon: Icons.dashboard_outlined),
  NavDestination(path: '/vendre', label: 'Nouvelle Vente', icon: Icons.add_shopping_cart_outlined),
  NavDestination(path: '/produits', label: 'Produits', icon: Icons.inventory_2_outlined),
  NavDestination(path: '/clients', label: 'Clients', icon: Icons.groups_outlined),
  NavDestination(path: '/fournisseurs', label: 'Fournisseurs', icon: Icons.local_shipping_outlined),
  NavDestination(path: '/mon-commerce', label: 'Aperçu', icon: Icons.analytics_outlined),
];

const _bottomDestinations = <NavDestination>[
  NavDestination(path: '/reglages', label: 'Réglages', icon: Icons.settings_outlined),
];

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final theme = Theme.of(context);

    bool isActive(String path) => path == '/' ? location == '/' : location.startsWith(path);

    return Container(
      width: AppSpacing.navWidth,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A101828),
            offset: Offset(0, 1),
            blurRadius: 3,
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.base),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Navigation principale
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final d in _mainDestinations)
                    _NavItem(destination: d, active: isActive(d.path)),
                ],
              ),
            ),
          ),
          // Navigation du bas (Réglages)
          for (final d in _bottomDestinations)
            _NavItem(destination: d, active: isActive(d.path)),
          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }
}



class _NavItem extends StatelessWidget {
  const _NavItem({required this.destination, required this.active});

  final NavDestination destination;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: active ? theme.colorScheme.secondaryContainer : Colors.transparent,
      child: InkWell(
        onTap: () => context.go(destination.path),
        hoverColor: theme.colorScheme.surfaceContainer,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 4,
                color: active ? theme.colorScheme.primary : Colors.transparent,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(destination.icon, color: color, size: 24),
              const SizedBox(height: AppSpacing.xs),
              Text(
                destination.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
