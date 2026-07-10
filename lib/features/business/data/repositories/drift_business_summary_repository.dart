import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/business_summary.dart';
import '../../domain/repositories/business_summary_repository.dart';

/// Implémentation Drift de [BusinessSummaryRepository] : tout en agrégats SQL.
class DriftBusinessSummaryRepository implements BusinessSummaryRepository {
  DriftBusinessSummaryRepository(this._db);

  final AppDatabase _db;

  @override
  Future<BusinessSummary> load(DateTime now) async {
    final startOfMonth = DateTime(now.year, now.month);

    // Ventes et encaissements du mois en une seule requête.
    final salesSum = _db.sales.totalAmount.sum();
    final paidSum = _db.sales.amountPaid.sum();
    final monthRow = await (_db.selectOnly(_db.sales)
          ..addColumns([salesSum, paidSum])
          ..where(_db.sales.date.isBiggerOrEqualValue(startOfMonth)))
        .getSingle();

    // Créances = Σ(total − payé) sur toutes les ventes.
    final owedExpr = (_db.sales.totalAmount - _db.sales.amountPaid).sum();
    final owed = (await (_db.selectOnly(_db.sales)..addColumns([owedExpr]))
                .getSingle())
            .read(owedExpr) ??
        0;

    // Bénéfice du mois = Σ(line_total − arrondi(unit_cost × quantity)) par ligne.
    final profit = CustomExpression<int>(
      'COALESCE(SUM(sale_items.line_total - '
      'CAST(round(sale_items.unit_cost * sale_items.quantity) AS INTEGER)), 0)',
    );
    final monthProfit = (await (_db.selectOnly(_db.saleItems).join([
      innerJoin(_db.sales, _db.sales.id.equalsExp(_db.saleItems.saleId)),
    ])
              ..addColumns([profit])
              ..where(_db.sales.date.isBiggerOrEqualValue(startOfMonth)))
            .getSingle())
        .read(profit) ??
        0;

    return BusinessSummary(
      monthSales: monthRow.read(salesSum) ?? 0,
      monthProfit: monthProfit,
      owedToMe: owed,
      cashCollectedThisMonth: monthRow.read(paidSum) ?? 0,
    );
  }
}
