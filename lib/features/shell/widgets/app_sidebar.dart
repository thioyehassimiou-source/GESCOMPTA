import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../../core/providers/app_settings_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class NavDestination {
  const NavDestination({
    required this.path,
    required this.label,
    required this.icon,
    this.iconSelected,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData? iconSelected;
}

const _mainDestinations = <NavDestination>[
  NavDestination(
    path: '/',
    label: 'Tableau de bord',
    icon: Icons.dashboard_outlined,
    iconSelected: Icons.dashboard_rounded,
  ),
  NavDestination(
    path: '/vendre',
    label: 'Vente',
    icon: Icons.shopping_cart_outlined,
    iconSelected: Icons.shopping_cart_rounded,
  ),
  NavDestination(
    path: '/commandes',
    label: 'Commandes',
    icon: Icons.notifications_none_rounded,
    iconSelected: Icons.notifications_rounded,
  ),
  NavDestination(
    path: '/caisse',
    label: 'Caisse',
    icon: Icons.account_balance_wallet_outlined,
    iconSelected: Icons.account_balance_wallet_rounded,
  ),
  NavDestination(
    path: '/devis',
    label: 'Devis & Factures',
    icon: Icons.receipt_long_outlined,
    iconSelected: Icons.receipt_long_rounded,
  ),
  NavDestination(
    path: '/produits',
    label: 'Stock',
    icon: Icons.inventory_2_outlined,
    iconSelected: Icons.inventory_2_rounded,
  ),
  NavDestination(
    path: '/clients',
    label: 'Clients',
    icon: Icons.people_outline_rounded,
    iconSelected: Icons.people_rounded,
  ),
  NavDestination(
    path: '/credits',
    label: 'Crédits',
    icon: Icons.credit_card_outlined,
    iconSelected: Icons.credit_card_rounded,
  ),
  NavDestination(
    path: '/livraisons',
    label: 'Livraisons',
    icon: Icons.local_shipping_outlined,
    iconSelected: Icons.local_shipping_rounded,
  ),
  NavDestination(
    path: '/livreurs',
    label: 'Livreurs',
    icon: Icons.sports_motorsports_outlined,
    iconSelected: Icons.sports_motorsports_rounded,
  ),
  NavDestination(
    path: '/fournisseurs',
    label: 'Fournisseurs',
    icon: Icons.storefront_outlined,
    iconSelected: Icons.storefront_rounded,
  ),
  NavDestination(
    path: '/depenses',
    label: 'Dépenses',
    icon: Icons.money_off_outlined,
    iconSelected: Icons.money_off_rounded,
  ),
  NavDestination(
    path: '/rapports',
    label: 'Rapports',
    icon: Icons.bar_chart_outlined,
    iconSelected: Icons.bar_chart_rounded,
  ),
  NavDestination(
    path: '/equipe',
    label: 'Équipe',
    icon: Icons.badge_outlined,
    iconSelected: Icons.badge_rounded,
  ),
  NavDestination(
    path: '/reglages',
    label: 'Paramètres',
    icon: Icons.settings_outlined,
    iconSelected: Icons.settings_rounded,
  ),
];

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final settings = ref.watch(appSettingsProvider);
    final user = ref.watch(authProvider);

    bool isActive(String path) =>
        path == '/' ? location == '/' : location.startsWith(path);
        
    final destinations = _mainDestinations.where((d) {
      if (d.path == '/equipe' && user?.role.name == 'cashier') {
        return false;
      }
      return true;
    }).toList();

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          right: BorderSide(color: context.colors.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          // ── Logo & Marque ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                    image: settings.logoPath != null
                        ? DecorationImage(
                            image: FileImage(File(settings.logoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: settings.logoPath == null
                      ? Center(
                          child: Icon(
                            Icons.storefront_rounded,
                            color: context.colors.primary,
                            size: 22,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.businessName.isNotEmpty
                            ? settings.businessName
                            : "N'MaShop",
                        style: TextStyle(
                          color: context.colors.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Gestion Commerciale',
                        style: TextStyle(
                          color: context.colors.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.outlineVariant),
          // ── Navigation ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: 'MENU PRINCIPAL'),
                  for (final d in _mainDestinations.take(5))
                    if (destinations.contains(d))
                      _NavItem(destination: d, active: isActive(d.path)),
                  const SizedBox(height: 8),
                  _SectionLabel(label: 'GESTION'),
                  for (final d in _mainDestinations.skip(5).take(5))
                    if (destinations.contains(d))
                      _NavItem(destination: d, active: isActive(d.path)),
                  const SizedBox(height: 8),
                  _SectionLabel(label: 'OUTILS'),
                  for (final d in _mainDestinations.skip(10))
                    if (destinations.contains(d))
                      _NavItem(destination: d, active: isActive(d.path)),
                ],
              ),
            ),
          ),
          // ── Profil ─────────────────────────────────────────────────────
          Divider(height: 1, color: context.colors.outlineVariant),
          const _SidebarProfile(),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SidebarProfile extends ConsumerWidget {
  const _SidebarProfile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.go('/reglages'),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    user?.initials ?? '?',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'Boutiquier',
                      style: TextStyle(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user?.role.name == 'admin' ? 'Admin' : 'Vendeur',
                      style: TextStyle(
                        color: context.colors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => ref.read(authProvider.notifier).lock(),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.logout_rounded, color: context.colors.onSurfaceVariant, size: 18),
                ),
              ),
            ],
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => context.go(destination.path),
          borderRadius: BorderRadius.circular(8),
          hoverColor: context.colors.primaryContainer.withValues(alpha: 0.5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: active ? context.colors.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  active
                      ? (destination.iconSelected ?? destination.icon)
                      : destination.icon,
                  color: active ? context.colors.primary : context.colors.onSurface,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    destination.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? context.colors.primary : context.colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
