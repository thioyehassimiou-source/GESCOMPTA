import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
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
  NavDestination(path: '/assistant', label: 'Assistant IA', icon: Icons.smart_toy_outlined),
  NavDestination(path: '/reglages', label: 'Réglages', icon: Icons.settings_outlined),
];

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    bool isActive(String path) => path == '/' ? location == '/' : location.startsWith(path);

    return Container(
      width: AppSpacing.navWidth,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: AppColors.onPrimaryContainer,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
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
    final color = active ? AppColors.primary : AppColors.onSurfaceVariant;
    
    return Material(
      color: active ? AppColors.secondaryContainer : Colors.transparent,
      child: InkWell(
        onTap: () => context.go(destination.path),
        hoverColor: AppColors.surfaceContainer,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 4,
                color: active ? AppColors.primary : Colors.transparent,
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
