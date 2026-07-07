import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gescompta/core/database/database.dart';
import 'package:gescompta/core/domain/payment_method.dart';
import 'package:gescompta/features/sales/data/repositories/drift_accounting_repository.dart';
import 'package:gescompta/features/sales/data/repositories/drift_product_repository.dart';
import 'package:gescompta/features/sales/data/repositories/drift_sale_repository.dart';
import 'package:gescompta/features/sales/data/repositories/drift_stock_repository.dart';
import 'package:gescompta/features/sales/data/services/drift_sale_service.dart';
import 'package:gescompta/features/sales/domain/accounting/syscohada_accounts.dart';
import 'package:gescompta/features/sales/domain/accounting/syscohada_sale_posting_policy.dart';
import 'package:gescompta/features/sales/domain/entities/sale_draft.dart';
import 'package:gescompta/features/sales/domain/errors.dart';
import 'package:gescompta/features/sales/domain/usecases/record_sale.dart';

/// Banc d'essai du moteur : vraie base en mémoire, IDs déterministes, horloge figée.
class _Engine {
  _Engine(this.db) {
    var seq = 0;
    String nextId() => 'id-${seq++}';
    final fixedClock = DateTime(2026, 7, 7, 10);

    final service = DriftSaleService(
      db: db,
      products: DriftProductRepository(db),
      stock: DriftStockRepository(db, idGenerator: nextId),
      sales: DriftSaleRepository(db),
      accounting: DriftAccountingRepository(db, idGenerator: nextId),
      postingPolicy: const SyscohadaSalePostingPolicy(),
      idGenerator: nextId,
      clock: () => fixedClock,
    );
    useCase = RecordSaleUseCase(service);
  }

  final AppDatabase db;
  late final RecordSaleUseCase useCase;
}

Future<void> _addProduct(
  AppDatabase db, {
  required String id,
  required String name,
  int salePrice = 0,
  double stock = 0,
  double cmp = 0,
  String unit = 'pièce',
}) {
  return db.into(db.products).insert(ProductsCompanion.insert(
        id: id,
        name: name,
        salePrice: Value(salePrice),
        stockQuantity: Value(stock),
        weightedAverageCost: Value(cmp),
        unit: Value(unit),
      ));
}

Future<int> _debitOf(AppDatabase db, String code) async {
  final lines = await (db.select(db.journalLines)
        ..where((t) => t.accountCode.equals(code)))
      .get();
  return lines.fold<int>(0, (s, l) => s + l.debit);
}

Future<int> _creditOf(AppDatabase db, String code) async {
  final lines = await (db.select(db.journalLines)
        ..where((t) => t.accountCode.equals(code)))
      .get();
  return lines.fold<int>(0, (s, l) => s + l.credit);
}

void main() {
  late AppDatabase db;
  late _Engine engine;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    engine = _Engine(db);
  });

  tearDown(() => db.close());

  test('Vente normale en espèces : vente, ligne, stock, encaissement', () async {
    await _addProduct(db,
        id: 'p1', name: 'Huile', salePrice: 150000, stock: 10, cmp: 100000);

    final result = await engine.useCase(SaleDraft(
      lines: const [SaleDraftLine(productId: 'p1', quantity: 2, unitPrice: 150000)],
      tenders: const [PaymentTender(method: PaymentMethod.cash, amount: 300000)],
    ));

    expect(result, isA<RecordSaleSuccess>());
    final sale = (result as RecordSaleSuccess).sale;
    expect(sale.total, 300000);
    expect(sale.amountPaid, 300000);
    expect(sale.creditAmount, 0);
    expect(sale.dominantMethod, PaymentMethod.cash);
    expect(sale.reference, 'V-2026-000001');

    final sales = await db.select(db.sales).get();
    expect(sales, hasLength(1));
    final items = await db.select(db.saleItems).get();
    expect(items, hasLength(1));
    expect(items.single.unitCost, 100000);

    final product = await (db.select(db.products)
          ..where((t) => t.id.equals('p1')))
        .getSingle();
    expect(product.stockQuantity, 8); // 10 - 2
  });

  test('Bénéfice = total − coût des marchandises (CMP)', () async {
    await _addProduct(db,
        id: 'p1', name: 'Sucre', salePrice: 12000, stock: 100, cmp: 9000);

    final result = await engine.useCase(SaleDraft(
      lines: const [SaleDraftLine(productId: 'p1', quantity: 5, unitPrice: 12000)],
      tenders: const [PaymentTender(method: PaymentMethod.cash, amount: 60000)],
    )) as RecordSaleSuccess;

    // 5 × 12000 = 60000 ; coût 5 × 9000 = 45000 ; marge = 15000.
    expect(result.sale.total, 60000);
    expect(result.sale.profit, 15000);
  });

  test('Vente multi-produits : totaux, lignes et mouvements corrects', () async {
    await _addProduct(db,
        id: 'p1', name: 'Huile', salePrice: 150000, stock: 10, cmp: 100000);
    await _addProduct(db,
        id: 'p2', name: 'Riz', salePrice: 50000, stock: 20, cmp: 40000);

    final result = await engine.useCase(SaleDraft(
      lines: const [
        SaleDraftLine(productId: 'p1', quantity: 1, unitPrice: 150000),
        SaleDraftLine(productId: 'p2', quantity: 3, unitPrice: 50000),
      ],
      tenders: const [PaymentTender(method: PaymentMethod.cash, amount: 300000)],
    )) as RecordSaleSuccess;

    expect(result.sale.total, 300000); // 150000 + 150000
    expect(result.sale.profit, 300000 - (100000 + 3 * 40000)); // 80000

    final items = await db.select(db.saleItems).get();
    expect(items, hasLength(2));

    final movements = await db.select(db.stockMovements).get();
    expect(movements, hasLength(2));
    expect(movements.every((m) => m.quantity < 0), isTrue); // sorties
  });

  test('Mouvements de stock : sortie négative, type vente, coût figé', () async {
    await _addProduct(db,
        id: 'p1', name: 'Lait', salePrice: 8000, stock: 15, cmp: 6000);

    await engine.useCase(SaleDraft(
      lines: const [SaleDraftLine(productId: 'p1', quantity: 4, unitPrice: 8000)],
      tenders: const [PaymentTender(method: PaymentMethod.cash, amount: 32000)],
    ));

    final movement = (await db.select(db.stockMovements).get()).single;
    expect(movement.quantity, -4);
    expect(movement.unitCost, 6000);
    expect(movement.sourceReference, 'V-2026-000001');
  });

  test('Écritures SYSCOHADA (espèces) : équilibrées, bons comptes', () async {
    await _addProduct(db,
        id: 'p1', name: 'Huile', salePrice: 150000, stock: 10, cmp: 100000);

    await engine.useCase(SaleDraft(
      lines: const [SaleDraftLine(productId: 'p1', quantity: 2, unitPrice: 150000)],
      tenders: const [PaymentTender(method: PaymentMethod.cash, amount: 300000)],
    ));

    // 2 pièces : vente + sortie de stock.
    final entries = await db.select(db.journalEntries).get();
    expect(entries, hasLength(2));

    // Pièce vente : débit 571 = 300000, crédit 701 = 300000.
    expect(await _debitOf(db, SyscohadaAccounts.cash), 300000);
    expect(await _creditOf(db, SyscohadaAccounts.merchandiseSales), 300000);
    // Pièce coût : débit 6031 = 200000, crédit 311 = 200000.
    expect(await _debitOf(db, SyscohadaAccounts.stockVariation), 200000);
    expect(await _creditOf(db, SyscohadaAccounts.merchandiseStock), 200000);

    // Chaque pièce est équilibrée.
    for (final e in entries) {
      final lines = await (db.select(db.journalLines)
            ..where((t) => t.entryId.equals(e.id)))
          .get();
      final debit = lines.fold(0, (s, l) => s + l.debit);
      final credit = lines.fold(0, (s, l) => s + l.credit);
      expect(debit, credit, reason: 'Pièce ${e.reference} déséquilibrée');
    }
  });

  test('Vente Mobile Money : encaissement au compte 551', () async {
    await _addProduct(db,
        id: 'p1', name: 'Savon', salePrice: 5000, stock: 30, cmp: 3000);

    final result = await engine.useCase(SaleDraft(
      lines: const [SaleDraftLine(productId: 'p1', quantity: 2, unitPrice: 5000)],
      tenders: const [
        PaymentTender(method: PaymentMethod.mobileMoney, amount: 10000)
      ],
    )) as RecordSaleSuccess;

    expect(result.sale.dominantMethod, PaymentMethod.mobileMoney);
    expect(await _debitOf(db, SyscohadaAccounts.mobileMoney), 10000);
    expect(await _debitOf(db, SyscohadaAccounts.cash), 0);
  });

  test('Vente Banque : encaissement au compte 521', () async {
    await _addProduct(db,
        id: 'p1', name: 'Ciment', salePrice: 90000, stock: 50, cmp: 75000);

    final result = await engine.useCase(SaleDraft(
      lines: const [SaleDraftLine(productId: 'p1', quantity: 1, unitPrice: 90000)],
      tenders: const [PaymentTender(method: PaymentMethod.bank, amount: 90000)],
    )) as RecordSaleSuccess;

    expect(result.sale.dominantMethod, PaymentMethod.bank);
    expect(await _debitOf(db, SyscohadaAccounts.bank), 90000);
  });

  test('Vente à crédit : créance client (411) et amountPaid partiel', () async {
    await db.into(db.customers).insert(
        CustomersCompanion.insert(id: 'c1', name: 'Mamadou'));
    await _addProduct(db,
        id: 'p1', name: 'Tissu', salePrice: 200000, stock: 10, cmp: 150000);

    // Payé 50000 en espèces, reste 150000 à crédit.
    final result = await engine.useCase(SaleDraft(
      customerId: 'c1',
      lines: const [SaleDraftLine(productId: 'p1', quantity: 1, unitPrice: 200000)],
      tenders: const [PaymentTender(method: PaymentMethod.cash, amount: 50000)],
    )) as RecordSaleSuccess;

    expect(result.sale.total, 200000);
    expect(result.sale.amountPaid, 50000);
    expect(result.sale.creditAmount, 150000);
    expect(result.sale.isCredit, isTrue);

    // Comptablement : débit 571 = 50000, débit 411 = 150000, crédit 701 = 200000.
    expect(await _debitOf(db, SyscohadaAccounts.cash), 50000);
    expect(await _debitOf(db, SyscohadaAccounts.clients), 150000);
    expect(await _creditOf(db, SyscohadaAccounts.merchandiseSales), 200000);

    final sale = (await db.select(db.sales).get()).single;
    expect(sale.amountPaid, 50000);
    expect(sale.totalAmount - sale.amountPaid, 150000); // reste dû
  });

  test('Crédit sans client : refus (validation), rien enregistré', () async {
    await _addProduct(db,
        id: 'p1', name: 'Tissu', salePrice: 200000, stock: 10, cmp: 150000);

    final result = await engine.useCase(SaleDraft(
      lines: const [SaleDraftLine(productId: 'p1', quantity: 1, unitPrice: 200000)],
      tenders: const [], // rien payé ⇒ tout à crédit
    ));

    expect(result, isA<RecordSaleFailure>());
    expect((result as RecordSaleFailure).error, isA<CreditRequiresCustomerError>());
    expect(await db.select(db.sales).get(), isEmpty);
  });

  test('Stock insuffisant : échec + ROLLBACK complet', () async {
    await _addProduct(db,
        id: 'p1', name: 'Huile', salePrice: 150000, stock: 1, cmp: 100000);

    final result = await engine.useCase(SaleDraft(
      lines: const [SaleDraftLine(productId: 'p1', quantity: 5, unitPrice: 150000)],
      tenders: const [PaymentTender(method: PaymentMethod.cash, amount: 750000)],
    ));

    expect(result, isA<RecordSaleFailure>());
    expect((result as RecordSaleFailure).error, isA<InsufficientStockError>());

    // Rien ne doit subsister : ni vente, ni ligne, ni mouvement, ni écriture.
    expect(await db.select(db.sales).get(), isEmpty);
    expect(await db.select(db.saleItems).get(), isEmpty);
    expect(await db.select(db.stockMovements).get(), isEmpty);
    expect(await db.select(db.journalEntries).get(), isEmpty);
    expect(await db.select(db.journalLines).get(), isEmpty);

    // Le stock d'origine est intact.
    final product =
        await (db.select(db.products)..where((t) => t.id.equals('p1'))).getSingle();
    expect(product.stockQuantity, 1);
  });

  test('Vente vide : refus immédiat', () async {
    final result = await engine.useCase(const SaleDraft(lines: [], tenders: []));
    expect(result, isA<RecordSaleFailure>());
    expect((result as RecordSaleFailure).error, isA<EmptySaleError>());
  });

  test('Numérotation continue des ventes', () async {
    await _addProduct(db, id: 'p1', name: 'X', salePrice: 1000, stock: 100, cmp: 500);

    final r1 = await engine.useCase(SaleDraft(
      lines: const [SaleDraftLine(productId: 'p1', quantity: 1, unitPrice: 1000)],
      tenders: const [PaymentTender(method: PaymentMethod.cash, amount: 1000)],
    )) as RecordSaleSuccess;
    final r2 = await engine.useCase(SaleDraft(
      lines: const [SaleDraftLine(productId: 'p1', quantity: 1, unitPrice: 1000)],
      tenders: const [PaymentTender(method: PaymentMethod.cash, amount: 1000)],
    )) as RecordSaleSuccess;

    expect(r1.sale.reference, 'V-2026-000001');
    expect(r2.sale.reference, 'V-2026-000002');
  });
}
