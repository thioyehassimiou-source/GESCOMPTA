import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gescompta/core/database/database.dart';
import 'package:gescompta/features/dashboard/data/repositories/drift_dashboard_repository.dart';

/// Vérifie que les indicateurs de l'accueil sont calculés correctement par les
/// agrégats SQL (mêmes chiffres que l'ancien calcul en RAM), en injectant un
/// `now` fixe pour des plages de dates déterministes.
void main() {
  late AppDatabase db;
  late DriftDashboardRepository repo;

  // Mardi 2026-07-10 midi. startToday = 2026-07-10, startWeek = 2026-07-03.
  final now = DateTime(2026, 7, 10, 12);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftDashboardRepository(db);

    // Produits : A sous le seuil (2 <= 5), B au-dessus (100 > 10).
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'A',
          name: 'Sucre',
          stockQuantity: const Value(2),
          lowStockThreshold: const Value(5),
        ));
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'B',
          name: 'Riz',
          stockQuantity: const Value(100),
          lowStockThreshold: const Value(10),
        ));

    Future<void> sale(
      String id,
      DateTime date,
      int total,
      int paid,
      String productId,
      String label,
      double qty,
      int unitPrice,
      double unitCost,
      int lineTotal,
    ) async {
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
            productId: productId,
            label: label,
            quantity: qty,
            unitPrice: unitPrice,
            unitCost: Value(unitCost),
            lineTotal: lineTotal,
          ));
    }

    // S1 aujourd'hui : payée. Marge = 30000 - round(6000*3) = 12000.
    await sale('s1', DateTime(2026, 7, 10, 10), 30000, 30000, 'A', 'Sucre', 3,
        10000, 6000, 30000);
    // S2 hier : crédit (reste dû 15000). Marge = 20000 - round(5000*2) = 10000.
    await sale('s2', DateTime(2026, 7, 9, 10), 20000, 5000, 'B', 'Riz', 2,
        10000, 5000, 20000);
    // S3 cette semaine (plus ancienne) : payée.
    await sale('s3', DateTime(2026, 7, 6, 10), 7000, 7000, 'B', 'Riz', 1, 7000,
        3000, 7000);

    // Trésorerie : une écriture avec une ligne au débit d'un compte de classe 5.
    final cashCode = (await (db.select(db.accounts)
                  ..where((a) => a.code.like('5%'))
                  ..limit(1))
                .getSingleOrNull())
            ?.code ??
        '571';
    await db.into(db.accounts).insertOnConflictUpdate(AccountsCompanion.insert(
          code: cashCode,
          label: 'Caisse',
          accountClass: 5,
        ));
    await db.into(db.journalEntries).insert(JournalEntriesCompanion.insert(
          id: 'je1',
          reference: 'EC-1',
          description: 'Encaissement S1',
        ));
    await db.into(db.journalLines).insert(JournalLinesCompanion.insert(
          id: 'jl1',
          entryId: 'je1',
          accountCode: cashCode,
          label: 'Caisse',
          debit: const Value(30000),
        ));
  });

  tearDown(() async => db.close());

  test('agrégats de l\'accueil', () async {
    final s = await repo.load(now);

    expect(s.todaySales, 30000);
    expect(s.yesterdaySales, 20000);
    expect(s.todayProfit, 12000);
    expect(s.yesterdayProfit, 10000);
    // Cette semaine = S1 + S2 + S3 ; semaine précédente = aucune.
    expect(s.thisWeekSales, 57000);
    expect(s.prevWeekSales, 0);
    // Créances : seule S2 doit (15000) ; owed somme tous les restes.
    expect(s.owed, 15000);
    expect(s.owedCount, 1);
    expect(s.cashAvailable, 30000);
  });

  test('bas stock et ventes récentes', () async {
    final s = await repo.load(now);

    expect(s.lowStock, hasLength(1));
    expect(s.lowStock.single.name, 'Sucre');

    // Triées de la plus récente à la plus ancienne : S1, S2, S3.
    expect(s.recentSales.map((r) => r.title).toList(),
        ['Sucre', 'Riz', 'Riz']);
    expect(s.recentSales.first.amount, 30000);
    expect(s.recentSales.first.paid, isTrue); // S1 payée
    expect(s.recentSales[1].paid, isFalse); // S2 crédit
  });
}
