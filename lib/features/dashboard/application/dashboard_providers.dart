import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../data/repositories/drift_dashboard_repository.dart';
import '../domain/entities/dashboard_snapshot.dart';
import '../domain/repositories/dashboard_repository.dart';

/// Une vente récente, prête à l'affichage (langage commerçant).
class RecentSaleView {
  const RecentSaleView({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.date,
    required this.amount,
    required this.paid,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final DateTime date;
  final int amount;
  final bool paid;
}

/// Toutes les données de l'écran Accueil. Les agrégats viennent d'un
/// [DashboardRepository] (calculs SQL) ; cette couche ne fait que dériver les
/// variations en % et habiller les ventes récentes pour l'affichage.
class DashboardData {
  const DashboardData({
    required this.todaySales,
    required this.todayProfit,
    required this.owed,
    required this.owedCount,
    required this.cashAvailable,
    required this.lowStock,
    required this.recentSales,
    required this.salesGrowth,
    required this.profitGrowth,
    required this.weeklyGrowth,
  });

  final int todaySales;
  final int todayProfit;
  final int owed;
  final int owedCount;
  final int cashAvailable;
  final List<LowStockItem> lowStock;
  final List<RecentSaleView> recentSales;

  /// Variations en % (null si pas de référence antérieure).
  final double? salesGrowth;
  final double? profitGrowth;
  final double? weeklyGrowth;
}

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DriftDashboardRepository(ref.watch(databaseProvider)),
);

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final snapshot = await ref.watch(dashboardRepositoryProvider).load(DateTime.now());

  double? growth(int current, int previous) =>
      previous <= 0 ? null : (current - previous) / previous * 100;

  return DashboardData(
    todaySales: snapshot.todaySales,
    todayProfit: snapshot.todayProfit,
    owed: snapshot.owed,
    owedCount: snapshot.owedCount,
    cashAvailable: snapshot.cashAvailable,
    lowStock: snapshot.lowStock,
    recentSales: [
      for (final r in snapshot.recentSales)
        RecentSaleView(
          title: r.title,
          subtitle: r.subtitle,
          icon: Icons.shopping_bag_outlined,
          date: r.date,
          amount: r.amount,
          paid: r.paid,
        ),
    ],
    salesGrowth: growth(snapshot.todaySales, snapshot.yesterdaySales),
    profitGrowth: growth(snapshot.todayProfit, snapshot.yesterdayProfit),
    weeklyGrowth: growth(snapshot.thisWeekSales, snapshot.prevWeekSales),
  );
});
