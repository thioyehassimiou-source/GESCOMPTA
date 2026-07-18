import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/credit_summary.dart';
import '../../domain/repositories/receivables_repository.dart';

/// Implémentation Drift de [ReceivablesRepository].
///
/// Le solde de chaque client est agrégé côté SQL (GROUP BY client sur les ventes
/// non soldées) ; aucune table n'est chargée en entier.
class DriftReceivablesRepository implements ReceivablesRepository {
  DriftReceivablesRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<CreditSummary>> watchCreditSummaries() {
    final balance = (_db.sales.totalAmount - _db.sales.amountPaid).sum();
    final salesCount = _db.sales.id.count();
    final lastSale = _db.sales.date.max();

    final query = _db.selectOnly(_db.sales).join([
      innerJoin(
        _db.customers,
        _db.customers.id.equalsExp(_db.sales.customerId),
      ),
    ])
      ..addColumns([
        _db.sales.customerId,
        _db.customers.name,
        _db.customers.phone,
        balance,
        salesCount,
        lastSale,
      ])
      // Ne compter que les ventes encore dues.
      ..where(_db.sales.totalAmount.isBiggerThan(_db.sales.amountPaid))
      ..groupBy([_db.sales.customerId])
      ..orderBy([OrderingTerm(expression: balance, mode: OrderingMode.desc)]);

    return query.watch().map((rows) => rows
        .map((r) => CreditSummary(
              customerId: r.read(_db.sales.customerId)!,
              customerName: r.read(_db.customers.name)!,
              customerPhone: r.read(_db.customers.phone),
              balance: r.read(balance) ?? 0,
              salesCount: r.read(salesCount) ?? 0,
              lastSaleDate: r.read(lastSale)!,
            ))
        .toList(growable: false));
  }
  @override
  Future<List<PaymentHistoryItem>> getPaymentHistory(String customerId) async {
    final query = _db.select(_db.creditPayments)
      ..where((p) => p.customerId.equals(customerId))
      ..orderBy([(p) => OrderingTerm(expression: p.date, mode: OrderingMode.desc)]);

    final rows = await query.get();
    return rows.map((r) => PaymentHistoryItem(
      amount: r.amount,
      date: r.date,
    )).toList();
  }
}
