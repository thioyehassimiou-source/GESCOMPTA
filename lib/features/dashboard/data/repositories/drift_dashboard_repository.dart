import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Implémentation Drift de [DashboardRepository].
///
/// Chaque indicateur est une requête agrégée (SUM/COUNT) ou une requête bornée
/// (5 ventes récentes, produits sous le seuil) : aucune table complète n'est
/// chargée en mémoire.
class DriftDashboardRepository implements DashboardRepository {
  DriftDashboardRepository(this._db);

  final AppDatabase _db;

  @override
  Future<DashboardSnapshot> load(DateTime now) async {
    final startToday = DateTime(now.year, now.month, now.day);
    final endToday = startToday.add(const Duration(days: 1));
    final startYesterday = startToday.subtract(const Duration(days: 1));
    final startWeek = startToday.subtract(const Duration(days: 7));
    final startPrevWeek = startToday.subtract(const Duration(days: 14));

    return DashboardSnapshot(
      todaySales: await _salesSum(startToday, endToday),
      yesterdaySales: await _salesSum(startYesterday, startToday),
      todayProfit: await _profit(startToday, endToday),
      yesterdayProfit: await _profit(startYesterday, startToday),
      thisWeekSales: await _salesSum(startWeek, endToday),
      prevWeekSales: await _salesSum(startPrevWeek, startWeek),
      owed: await _owed(),
      owedCount: await _owedCount(),
      cashAvailable: await _cashAvailable(),
      lowStock: await _lowStock(),
      recentSales: await _recentSales(),
    );
  }

  /// Σ(total_amount) des ventes sur [start, end).
  Future<int> _salesSum(DateTime start, DateTime end) async {
    final sum = _db.sales.totalAmount.sum();
    final q = _db.selectOnly(_db.sales)
      ..addColumns([sum])
      ..where(_db.sales.date.isBiggerOrEqualValue(start) &
          _db.sales.date.isSmallerThanValue(end));
    return (await q.getSingle()).read(sum) ?? 0;
  }

  /// Bénéfice = Σ(line_total − arrondi(unit_cost × quantity)) **par ligne**, sur
  /// les ventes de [start, end). L'arrondi par ligne reproduit exactement
  /// l'ancien calcul Dart.
  Future<int> _profit(DateTime start, DateTime end) async {
    final profit = CustomExpression<int>(
      'COALESCE(SUM(sale_items.line_total - '
      'CAST(round(sale_items.unit_cost * sale_items.quantity) AS INTEGER)), 0)',
    );
    final q = _db.selectOnly(_db.saleItems).join([
      innerJoin(_db.sales, _db.sales.id.equalsExp(_db.saleItems.saleId)),
    ])
      ..addColumns([profit])
      ..where(_db.sales.date.isBiggerOrEqualValue(start) &
          _db.sales.date.isSmallerThanValue(end));
    return (await q.getSingle()).read(profit) ?? 0;
  }

  /// Σ(total_amount − amount_paid) sur toutes les ventes.
  Future<int> _owed() async {
    final owed = (_db.sales.totalAmount - _db.sales.amountPaid).sum();
    final q = _db.selectOnly(_db.sales)..addColumns([owed]);
    return (await q.getSingle()).read(owed) ?? 0;
  }

  /// Nombre de ventes dont le total dépasse le montant réglé.
  Future<int> _owedCount() async {
    final count = _db.sales.id.count();
    final q = _db.selectOnly(_db.sales)
      ..addColumns([count])
      ..where(_db.sales.totalAmount.isBiggerThan(_db.sales.amountPaid));
    return (await q.getSingle()).read(count) ?? 0;
  }

  /// Solde des comptes de trésorerie (classe 5) = Σ(débit − crédit).
  Future<int> _cashAvailable() async {
    final balance = (_db.journalLines.debit - _db.journalLines.credit).sum();
    final q = _db.selectOnly(_db.journalLines)
      ..addColumns([balance])
      ..where(_db.journalLines.accountCode.like('5%'));
    return (await q.getSingle()).read(balance) ?? 0;
  }

  Future<List<LowStockItem>> _lowStock() async {
    final rows = await (_db.select(_db.products)
          ..where((p) =>
              p.isActive.equals(true) &
              p.stockQuantity.isSmallerOrEqual(p.lowStockThreshold))
          ..orderBy([(p) => OrderingTerm(expression: p.stockQuantity)]))
        .get();
    return rows
        .map((r) => LowStockItem(
              name: r.name,
              unit: r.unit,
              stockQuantity: r.stockQuantity,
            ))
        .toList(growable: false);
  }

  Future<List<RecentSale>> _recentSales() async {
    final sales = await (_db.select(_db.sales)
          ..orderBy([
            (s) => OrderingTerm(expression: s.date, mode: OrderingMode.desc),
          ])
          ..limit(5))
        .get();
    if (sales.isEmpty) return const [];

    final saleIds = sales.map((s) => s.id).toList();
    final customerIds =
        sales.map((s) => s.customerId).whereType<String>().toSet().toList();

    // Lignes des 5 ventes seulement (borné), regroupées par vente.
    final items = await (_db.select(_db.saleItems)
          ..where((i) => i.saleId.isIn(saleIds)))
        .get();
    final itemsBySale = <String, List<SaleItem>>{};
    for (final it in items) {
      itemsBySale.putIfAbsent(it.saleId, () => []).add(it);
    }

    final customerNames = <String, String>{};
    if (customerIds.isNotEmpty) {
      final custs = await (_db.select(_db.customers)
            ..where((c) => c.id.isIn(customerIds)))
          .get();
      for (final c in custs) {
        customerNames[c.id] = c.name;
      }
    }

    return sales.map((s) {
      final its = itemsBySale[s.id] ?? const [];
      final first = its.isNotEmpty ? its.first.label : 'Vente';
      final extra = its.length > 1 ? ' +${its.length - 1}' : '';
      return RecentSale(
        title: '$first$extra',
        subtitle: s.customerId != null
            ? (customerNames[s.customerId] ?? 'Client')
            : 'Client comptoir',
        date: s.date,
        amount: s.totalAmount,
        paid: s.amountPaid >= s.totalAmount,
      );
    }).toList(growable: false);
  }
}
