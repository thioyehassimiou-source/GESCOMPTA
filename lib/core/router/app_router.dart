import 'package:go_router/go_router.dart';

import '../../features/business/presentation/business_summary_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/receivables/presentation/clients_screen.dart';
import '../../features/sales/presentation/sales_screen.dart';
import '../../features/settings/presentation/accountant_export_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/stock/presentation/products_screen.dart';
import '../../features/suppliers/presentation/suppliers_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: '/vendre',
          pageBuilder: (c, s) => const NoTransitionPage(child: SalesScreen()),
        ),
        GoRoute(
          path: '/produits',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: ProductsScreen()),
        ),
        GoRoute(
          path: '/clients',
          pageBuilder: (c, s) => const NoTransitionPage(child: ClientsScreen()),
        ),
        GoRoute(
          path: '/fournisseurs',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: SuppliersScreen()),
        ),
        GoRoute(
          path: '/mon-commerce',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: BusinessSummaryScreen()),
        ),
        GoRoute(
          path: '/reglages',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: SettingsScreen()),
          routes: [
            // Espace comptable : accessible uniquement depuis Réglages,
            // jamais dans le menu principal du commerçant.
            GoRoute(
              path: 'espace-comptable',
              pageBuilder: (c, s) =>
                  const NoTransitionPage(child: AccountantExportScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);
