import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/repositories/suppliers_repository.dart';
import '../../domain/supplier_summary.dart';

class DriftSuppliersRepository implements SuppliersRepository {
  DriftSuppliersRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<SupplierSummary>> watchSupplierSummaries() {
    final balance = (_db.purchases.totalAmount - _db.purchases.amountPaid)
        .sum();
    final purchasesCount = _db.purchases.id.count();
    final lastPurchase = _db.purchases.date.max();

    final query =
        _db.selectOnly(_db.purchases).join([
            innerJoin(
              _db.suppliers,
              _db.suppliers.id.equalsExp(_db.purchases.supplierId),
            ),
          ])
          ..addColumns([
            _db.purchases.supplierId,
            _db.suppliers.name,
            _db.suppliers.phone,
            balance,
            purchasesCount,
            lastPurchase,
          ])
          // Ne compter que les achats non soldés.
          ..where(
            _db.purchases.totalAmount.isBiggerThan(_db.purchases.amountPaid),
          )
          ..groupBy([_db.purchases.supplierId])
          ..orderBy([
            OrderingTerm(expression: balance, mode: OrderingMode.desc),
          ]);

    return query.watch().map(
      (rows) => rows
          .map(
            (r) => SupplierSummary(
              supplierId: r.read(_db.purchases.supplierId)!,
              supplierName: r.read(_db.suppliers.name)!,
              supplierPhone: r.read(_db.suppliers.phone),
              balance: r.read(balance) ?? 0,
              purchasesCount: r.read(purchasesCount) ?? 0,
              lastPurchaseDate: r.read(lastPurchase)!,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<List<SupplierPaymentHistoryItem>> getPaymentHistory(
    String supplierId,
  ) async {
    final query = _db.select(_db.supplierPayments)
      ..where((p) => p.supplierId.equals(supplierId))
      ..orderBy([
        (p) => OrderingTerm(expression: p.date, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();
    return rows
        .map((r) => SupplierPaymentHistoryItem(amount: r.amount, date: r.date))
        .toList();
  }

  @override
  Stream<List<RecentPurchaseView>> watchRecentPurchases() {
    final query =
        _db.select(_db.purchases).join([
            innerJoin(
              _db.suppliers,
              _db.suppliers.id.equalsExp(_db.purchases.supplierId),
            ),
          ])
          ..orderBy([
            OrderingTerm(
              expression: _db.purchases.date,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(30);

    return query.watch().map((rows) {
      return rows.map((row) {
        final purchase = row.readTable(_db.purchases);
        final supplier = row.readTable(_db.suppliers);
        return RecentPurchaseView(
          purchaseId: purchase.id,
          supplierName: supplier.name,
          date: purchase.date,
          totalAmount: purchase.totalAmount,
          amountPaid: purchase.amountPaid,
          isCancelled: purchase.isCancelled,
        );
      }).toList();
    });
  }
}
