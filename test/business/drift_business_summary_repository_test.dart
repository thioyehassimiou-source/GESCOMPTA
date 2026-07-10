import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gescompta/core/database/database.dart';
import 'package:gescompta/features/business/data/repositories/drift_business_summary_repository.dart';

/// Vérifie le résumé « Mon commerce » : sommes du mois en agrégats SQL, avec un
/// `now` fixe pour délimiter le mois courant.
void main() {
  late AppDatabase db;
  late DriftBusinessSummaryRepository repo;

  final now = DateTime(2026, 7, 10, 12); // startOfMonth = 2026-07-01

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftBusinessSummaryRepository(db);

    await db.into(db.products).insert(
        ProductsCompanion.insert(id: 'P', name: 'Produit'));

    Future<void> sale(String id, DateTime date, int total, int paid,
        double qty, double unitCost, int lineTotal) async {
      await db.into(db.sales).insert(SalesCompanion.insert(
            id: id,
            reference: 'V-$id',
            date: Value(date),
            totalAmount: Value(total),
            amountPaid: Value(paid),
          ));
      await db.into(db.saleItems).insert(SaleItemsCompanion.insert(
            id: 'item-$id',
            saleId: id,
            productId: 'P',
            label: 'Produit',
            quantity: qty,
            unitPrice: lineTotal ~/ qty.toInt(),
            unitCost: Value(unitCost),
            lineTotal: lineTotal,
          ));
    }

    // Ce mois : marge 12000 + 10000 = 22000.
    await sale('m1', DateTime(2026, 7, 5), 30000, 30000, 3, 6000, 30000);
    await sale('m2', DateTime(2026, 7, 8), 20000, 5000, 2, 5000, 20000);
    // Mois précédent : ignoré pour les totaux du mois, mais compte dans owedToMe.
    await sale('l1', DateTime(2026, 6, 20), 50000, 50000, 5, 4000, 50000);
  });

  tearDown(() async => db.close());

  test('résumé du mois courant', () async {
    final s = await repo.load(now);

    expect(s.monthSales, 50000); // 30000 + 20000
    expect(s.cashCollectedThisMonth, 35000); // 30000 + 5000
    expect(s.monthProfit, 22000); // 12000 + 10000
    // owedToMe couvre toutes les ventes : seule m2 doit encore 15000.
    expect(s.owedToMe, 15000);
  });
}
