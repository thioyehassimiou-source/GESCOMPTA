import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables/expenses.dart';
import '../../../core/database/tables/orders.dart';
import '../../../core/providers/database_provider.dart';

// ─── Modèles ─────────────────────────────────────────────────────────────────

class TopProduct {
  final String name;
  final int quantitySold;
  final int revenue;
  TopProduct({required this.name, required this.quantitySold, required this.revenue});
}

class ExpenseByCat {
  final ExpenseCategory category;
  final int total;
  ExpenseByCat({required this.category, required this.total});
}

class DailyRevenue {
  final DateTime date;
  final int revenue;
  final int profit;
  DailyRevenue({required this.date, required this.revenue, required this.profit});
}

class ReportData {
  final int revenue;          // CA total
  final int collected;        // Encaissé
  final int receivables;      // Créances (CA - Encaissé)
  final int grossProfit;      // Bénéfice brut (avant dépenses)
  final int totalExpenses;    // Dépenses
  final int netProfit;        // Bénéfice net
  final int salesCount;       // Nombre de ventes
  final int ordersCount;      // Nombre de commandes livrées
  final int ordersRevenue;    // CA des commandes livrées
  final List<TopProduct> topProducts;
  final List<ExpenseByCat> expensesByCategory;
  final List<DailyRevenue> dailyRevenues;

  ReportData({
    required this.revenue,
    required this.collected,
    required this.receivables,
    required this.grossProfit,
    required this.totalExpenses,
    required this.netProfit,
    required this.salesCount,
    required this.ordersCount,
    required this.ordersRevenue,
    required this.topProducts,
    required this.expensesByCategory,
    required this.dailyRevenues,
  });
}

// ─── Période sélectionnée ─────────────────────────────────────────────────────

enum ReportPeriod { today, week, month, year, custom }

class ReportRange {
  final DateTime start;
  final DateTime end;
  final ReportPeriod period;

  ReportRange({required this.start, required this.end, required this.period});

  static ReportRange forPeriod(ReportPeriod p, {DateTime? customStart, DateTime? customEnd}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (p) {
      case ReportPeriod.today:
        return ReportRange(start: today, end: today.add(const Duration(days: 1)), period: p);
      case ReportPeriod.week:
        return ReportRange(start: today.subtract(const Duration(days: 6)), end: today.add(const Duration(days: 1)), period: p);
      case ReportPeriod.month:
        return ReportRange(start: DateTime(now.year, now.month, 1), end: today.add(const Duration(days: 1)), period: p);
      case ReportPeriod.year:
        return ReportRange(start: DateTime(now.year, 1, 1), end: today.add(const Duration(days: 1)), period: p);
      case ReportPeriod.custom:
        return ReportRange(start: customStart ?? today, end: (customEnd ?? today).add(const Duration(days: 1)), period: p);
    }
  }

  String get label {
    switch (period) {
      case ReportPeriod.today: return 'Aujourd\'hui';
      case ReportPeriod.week: return 'Cette semaine';
      case ReportPeriod.month: return 'Ce mois';
      case ReportPeriod.year: return 'Cette année';
      case ReportPeriod.custom: return 'Personnalisé';
    }
  }
}

// ─── State Provider pour la période ──────────────────────────────────────────

class ReportRangeNotifier extends Notifier<ReportRange> {
  @override
  ReportRange build() => ReportRange.forPeriod(ReportPeriod.month);

  void updateRange(ReportRange range) {
    state = range;
  }
}

final reportRangeProvider = NotifierProvider<ReportRangeNotifier, ReportRange>(
  ReportRangeNotifier.new,
);

// ─── Provider de données ──────────────────────────────────────────────────────

final reportDataProvider = FutureProvider<ReportData>((ref) async {
  final db = ref.watch(databaseProvider);
  final range = ref.watch(reportRangeProvider);
  final start = range.start;
  final end = range.end;

  // 1. CA et encaissements
  final revenueExpr = db.sales.totalAmount.sum();
  final collectedExpr = db.sales.amountPaid.sum();
  final countExpr = db.sales.id.count();
  final revQuery = db.selectOnly(db.sales)
    ..addColumns([revenueExpr, collectedExpr, countExpr])
    ..where(
      db.sales.date.isBiggerOrEqualValue(start) &
      db.sales.date.isSmallerThanValue(end) &
      db.sales.isCancelled.equals(false),
    );
  final revRow = await revQuery.getSingle();
  final revenue = revRow.read(revenueExpr) ?? 0;
  final collected = revRow.read(collectedExpr) ?? 0;
  final salesCount = revRow.read(countExpr) ?? 0;

  // 2. Bénéfice brut
  final profitExpr = CustomExpression<int>(
    'COALESCE(SUM(sale_items.line_total - CAST(round(sale_items.unit_cost * sale_items.quantity) AS INTEGER)), 0)',
  );
  final profitQuery = db.selectOnly(db.saleItems).join([
    innerJoin(db.sales, db.sales.id.equalsExp(db.saleItems.saleId)),
  ])
    ..addColumns([profitExpr])
    ..where(
      db.sales.date.isBiggerOrEqualValue(start) &
      db.sales.date.isSmallerThanValue(end) &
      db.sales.isCancelled.equals(false),
    );
  final grossProfit = (await profitQuery.getSingle()).read(profitExpr) ?? 0;

  // 3. Dépenses
  final expExpr = db.expenses.amount.sum();
  final expQuery = db.selectOnly(db.expenses)
    ..addColumns([expExpr])
    ..where(
      db.expenses.date.isBiggerOrEqualValue(start) &
      db.expenses.date.isSmallerThanValue(end),
    );
  final totalExpenses = (await expQuery.getSingle()).read(expExpr) ?? 0;

  // 4. Commandes livrées
  final ordRevExpr = db.orders.totalAmount.sum();
  final ordCountExpr = db.orders.id.count();
  final ordQuery = db.selectOnly(db.orders)
    ..addColumns([ordRevExpr, ordCountExpr])
    ..where(
      db.orders.createdAt.isBiggerOrEqualValue(start) &
      db.orders.createdAt.isSmallerThanValue(end) &
      db.orders.status.equals(OrderStatus.delivered.index),
    );
  final ordRow = await ordQuery.getSingle();
  final ordersRevenue = ordRow.read(ordRevExpr) ?? 0;
  final ordersCount = ordRow.read(ordCountExpr) ?? 0;

  // 5. Top produits
  final qtyExpr = db.saleItems.quantity.sum();
  final salesRevExpr = db.saleItems.lineTotal.sum();
  final topQuery = db.selectOnly(db.saleItems).join([
    innerJoin(db.sales, db.sales.id.equalsExp(db.saleItems.saleId)),
  ])
    ..addColumns([db.saleItems.label, qtyExpr, salesRevExpr])
    ..where(
      db.sales.date.isBiggerOrEqualValue(start) &
      db.sales.date.isSmallerThanValue(end) &
      db.sales.isCancelled.equals(false),
    )
    ..groupBy([db.saleItems.label])
    ..orderBy([OrderingTerm(expression: qtyExpr, mode: OrderingMode.desc)])
    ..limit(5);
  final topRows = await topQuery.get();
  final topProducts = topRows.map((r) => TopProduct(
    name: r.read(db.saleItems.label)!,
    quantitySold: r.read(qtyExpr) ?? 0,
    revenue: r.read(salesRevExpr) ?? 0,
  )).toList();

  // 6. Dépenses par catégorie
  final catExpr = db.expenses.amount.sum();
  final catQuery = db.selectOnly(db.expenses)
    ..addColumns([db.expenses.category, catExpr])
    ..where(
      db.expenses.date.isBiggerOrEqualValue(start) &
      db.expenses.date.isSmallerThanValue(end),
    )
    ..groupBy([db.expenses.category])
    ..orderBy([OrderingTerm(expression: catExpr, mode: OrderingMode.desc)]);
  final catRows = await catQuery.get();
  final expensesByCategory = catRows.map((r) {
    final catIndex = r.read(db.expenses.category)!;
    return ExpenseByCat(
      category: ExpenseCategory.values[catIndex],
      total: r.read(catExpr) ?? 0,
    );
  }).toList();

  // 7. CA journalier (pour graphique)
  final allSales = await (db.select(db.sales)
    ..where((s) =>
      s.date.isBiggerOrEqualValue(start) &
      s.date.isSmallerThanValue(end) &
      s.isCancelled.equals(false))
  ).get();
  final allItems = allSales.isEmpty ? <SaleItem>[] : await (db.select(db.saleItems)
    ..where((i) => i.saleId.isIn(allSales.map((s) => s.id).toList()))
  ).get();
  final itemsBySale = <String, List<SaleItem>>{};
  for (final item in allItems) {
    itemsBySale.putIfAbsent(item.saleId, () => []).add(item);
  }

  final Map<DateTime, int> dailyRev = {};
  final Map<DateTime, int> dailyProfit = {};
  for (final s in allSales) {
    final day = DateTime(s.date.year, s.date.month, s.date.day);
    dailyRev[day] = (dailyRev[day] ?? 0) + s.totalAmount;
    final items = itemsBySale[s.id] ?? [];
    final p = items.fold<int>(0, (acc, i) => acc + i.lineTotal - (i.unitCost * i.quantity).round());
    dailyProfit[day] = (dailyProfit[day] ?? 0) + p;
  }
  final days = dailyRev.keys.toList()..sort();
  final dailyRevenues = days.map((d) => DailyRevenue(
    date: d,
    revenue: dailyRev[d] ?? 0,
    profit: dailyProfit[d] ?? 0,
  )).toList();

  return ReportData(
    revenue: revenue,
    collected: collected,
    receivables: revenue - collected,
    grossProfit: grossProfit,
    totalExpenses: totalExpenses,
    netProfit: grossProfit - totalExpenses,
    salesCount: salesCount,
    ordersCount: ordersCount,
    ordersRevenue: ordersRevenue,
    topProducts: topProducts,
    expensesByCategory: expensesByCategory,
    dailyRevenues: dailyRevenues,
  );
});
