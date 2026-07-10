import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

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

/// Toutes les données de l'écran Accueil, calculées en lecture seule à partir
/// des ventes, du stock et des écritures — sans toucher à la couche métier.
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
  final List<Product> lowStock;
  final List<RecentSaleView> recentSales;

  /// Variations en % (null si pas de référence antérieure).
  final double? salesGrowth;
  final double? profitGrowth;
  final double? weeklyGrowth;

}

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final startToday = DateTime(now.year, now.month, now.day);
  final startYesterday = startToday.subtract(const Duration(days: 1));
  final startWeek = startToday.subtract(const Duration(days: 7));
  final startPrevWeek = startToday.subtract(const Duration(days: 14));

  final sales = await db.select(db.sales).get();
  final items = await db.select(db.saleItems).get();
  final products = await db.select(db.products).get();
  final lines = await db.select(db.journalLines).get();
  final customers = await db.select(db.customers).get();
  final customerNames = {for (final c in customers) c.id: c.name};

  // Regroupe les lignes par vente (pour le libellé de la vente récente).
  final itemsBySale = <String, List<SaleItem>>{};
  for (final it in items) {
    itemsBySale.putIfAbsent(it.saleId, () => []).add(it);
  }

  int sumSales(DateTime start, DateTime end) => sales
      .where((s) => !s.date.isBefore(start) && s.date.isBefore(end))
      .fold(0, (sum, s) => sum + s.totalAmount);

  int sumProfit(DateTime start, DateTime end) {
    final ids = sales
        .where((s) => !s.date.isBefore(start) && s.date.isBefore(end))
        .map((s) => s.id)
        .toSet();
    return items
        .where((it) => ids.contains(it.saleId))
        .fold(0, (sum, it) => sum + it.lineTotal - (it.unitCost * it.quantity).round());
  }

  double? growth(int current, int previous) =>
      previous <= 0 ? null : (current - previous) / previous * 100;

  final todaySales = sumSales(startToday, now.add(const Duration(days: 1)));
  final yesterdaySales = sumSales(startYesterday, startToday);
  final todayProfit = sumProfit(startToday, now.add(const Duration(days: 1)));
  final yesterdayProfit = sumProfit(startYesterday, startToday);
  final thisWeek = sumSales(startWeek, now.add(const Duration(days: 1)));
  final prevWeek = sumSales(startPrevWeek, startWeek);

  final owed = sales.fold(0, (sum, s) => sum + (s.totalAmount - s.amountPaid));
  final owedCount = sales.where((s) => s.totalAmount > s.amountPaid).length;

  // Argent disponible = solde des comptes de trésorerie (classe 5).
  final cashAvailable = lines
      .where((l) => l.accountCode.startsWith('5'))
      .fold(0, (sum, l) => sum + l.debit - l.credit);

  final lowStock = products
      .where((p) => p.isActive && p.stockQuantity <= p.lowStockThreshold)
      .toList()
    ..sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));

  // Ventes récentes (5 dernières).
  final recent = [...sales]..sort((a, b) => b.date.compareTo(a.date));
  final recentSales = <RecentSaleView>[];
  for (final s in recent.take(5)) {
    final saleItems = itemsBySale[s.id] ?? const [];
    final first = saleItems.isNotEmpty ? saleItems.first.label : 'Vente';
    final extra = saleItems.length > 1 ? ' +${saleItems.length - 1}' : '';
    recentSales.add(RecentSaleView(
      title: '$first$extra',
      subtitle: s.customerId != null
          ? (customerNames[s.customerId] ?? 'Client')
          : 'Client comptoir',
      icon: Icons.shopping_bag_outlined,
      date: s.date,
      amount: s.totalAmount,
      paid: s.amountPaid >= s.totalAmount,
    ));
  }



  return DashboardData(
    todaySales: todaySales,
    todayProfit: todayProfit,
    owed: owed,
    owedCount: owedCount,
    cashAvailable: cashAvailable,
    lowStock: lowStock,
    recentSales: recentSales,
    salesGrowth: growth(todaySales, yesterdaySales),
    profitGrowth: growth(todayProfit, yesterdayProfit),
    weeklyGrowth: growth(thisWeek, prevWeek),
  );
});
