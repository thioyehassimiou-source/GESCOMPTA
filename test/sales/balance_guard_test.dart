import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gescompta/core/domain/payment_method.dart';
import 'package:gescompta/core/database/database.dart';
import 'package:gescompta/features/sales/data/repositories/drift_accounting_repository.dart';
import 'package:gescompta/features/sales/data/repositories/drift_product_repository.dart';
import 'package:gescompta/features/sales/data/repositories/drift_sale_repository.dart';
import 'package:gescompta/features/sales/data/repositories/drift_stock_repository.dart';
import 'package:gescompta/features/sales/data/services/drift_sale_service.dart';
import 'package:gescompta/features/sales/domain/accounting/journal_draft.dart';
import 'package:gescompta/features/sales/domain/accounting/sale_posting_policy.dart';
import 'package:gescompta/features/sales/domain/entities/sale_draft.dart';
import 'package:gescompta/features/sales/domain/errors.dart';
import 'package:gescompta/features/sales/domain/usecases/record_sale.dart';

/// Politique volontairement boguée : produit une pièce déséquilibrée (un débit
/// sans contrepartie au crédit). Simule un futur bug de comptabilisation.
class _UnbalancedPolicy implements SalePostingPolicy {
  const _UnbalancedPolicy();

  @override
  List<JournalEntryDraft> buildEntries(SalePostingContext context) => [
        JournalEntryDraft(
          date: context.date,
          description: 'Pièce déséquilibrée (test)',
          source: AccountingSource.sale,
          sourceId: context.saleId,
          lines: [
            JournalLineDraft.debit('571', 'Caisse', 1000),
            // Aucune ligne au crédit → Σ débit ≠ Σ crédit.
          ],
        ),
      ];
}

void main() {
  late AppDatabase db;
  late RecordSaleUseCase useCase;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    var seq = 0;
    String nextId() => 'id-${seq++}';
    final service = DriftSaleService(
      db: db,
      products: DriftProductRepository(db),
      stock: DriftStockRepository(db, idGenerator: nextId),
      sales: DriftSaleRepository(db),
      accounting: DriftAccountingRepository(db, idGenerator: nextId),
      postingPolicy: const _UnbalancedPolicy(),
      idGenerator: nextId,
      clock: () => DateTime(2026, 7, 7, 10),
    );
    useCase = RecordSaleUseCase(service);

    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'A',
          name: 'Sucre',
          salePrice: const Value(1000),
          stockQuantity: const Value(10),
          weightedAverageCost: const Value(600),
        ));
  });

  tearDown(() async => db.close());

  test('pièce déséquilibrée → échec et ROLLBACK complet (rien persisté)',
      () async {
    final result = await useCase(SaleDraft(
      lines: const [SaleDraftLine(productId: 'A', quantity: 1, unitPrice: 1000)],
      tenders: const [PaymentTender(method: PaymentMethod.cash, amount: 1000)],
    ));

    expect(result, isA<RecordSaleFailure>());
    expect((result as RecordSaleFailure).error, isA<UnbalancedEntryError>());

    // Rien ne doit subsister : la transaction entière est annulée.
    expect(await db.select(db.sales).get(), isEmpty);
    expect(await db.select(db.saleItems).get(), isEmpty);
    expect(await db.select(db.journalLines).get(), isEmpty);
    expect(await db.select(db.journalEntries).get(), isEmpty);
    expect(await db.select(db.stockMovements).get(), isEmpty);
    // Le stock du produit est intact.
    final p =
        await (db.select(db.products)..where((t) => t.id.equals('A'))).getSingle();
    expect(p.stockQuantity, 10);
  });
}
