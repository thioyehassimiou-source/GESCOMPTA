import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gescompta/core/database/database.dart';
import 'package:gescompta/core/domain/payment_method.dart';
import 'package:gescompta/core/providers/database_provider.dart';
import 'package:gescompta/features/sales/application/sale_cart_controller.dart';
import 'package:gescompta/features/sales/domain/usecases/record_sale.dart';
import 'package:gescompta/features/stock/domain/entities/product.dart' as catalog;

/// Vue catalogue du produit seedé « p1 » (ce que le picker fournit au panier).
catalog.Product _p1() => catalog.Product(
      id: 'p1',
      name: 'Huile',
      reference: null,
      unit: 'pièce',
      purchasePrice: 100000,
      salePrice: 150000,
      stockQuantity: 10,
      lowStockThreshold: 0,
      weightedAverageCost: 100000,
      isActive: true,
      createdAt: DateTime(2026),
    );

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'p1',
          name: 'Huile',
          salePrice: const Value(150000),
          stockQuantity: const Value(10),
          weightedAverageCost: const Value(100000),
        ));
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('Panier → moteur : la vente est enregistrée et le panier remis à zéro',
      () async {
    final controller = container.read(saleCartControllerProvider.notifier);
    final product = _p1();

    controller.addProduct(product);
    controller.addProduct(product); // 2 unités
    expect(container.read(saleCartControllerProvider).total, 300000);

    final result = await controller.submit();

    expect(result, isA<RecordSaleSuccess>());
    // Panier vidé après succès.
    expect(container.read(saleCartControllerProvider).isEmpty, isTrue);
    // La vente et son écriture existent en base.
    expect(await db.select(db.sales).get(), hasLength(1));
    expect(await db.select(db.journalEntries).get(), hasLength(2));
    // Stock décrémenté.
    final p = await (db.select(db.products)..where((t) => t.id.equals('p1')))
        .getSingle();
    expect(p.stockQuantity, 8);
  });

  test('Vente à crédit sans nom de client : refus', () async {
    final controller = container.read(saleCartControllerProvider.notifier);
    final product = _p1();

    controller.addProduct(product);
    controller.setMethod(PaymentMethod.credit);

    final result = await controller.submit();
    expect(result, isA<RecordSaleFailure>());
    expect(await db.select(db.sales).get(), isEmpty);
  });

  test('Vente à crédit avec nom : client créé, créance enregistrée', () async {
    final controller = container.read(saleCartControllerProvider.notifier);
    final product = _p1();

    controller.addProduct(product);
    controller.setMethod(PaymentMethod.credit);
    controller.setCustomerName('Fatoumata');

    final result = await controller.submit();
    expect(result, isA<RecordSaleSuccess>());

    final customers = await db.select(db.customers).get();
    expect(customers, hasLength(1));
    expect(customers.single.name, 'Fatoumata');

    final sale = (await db.select(db.sales).get()).single;
    expect(sale.amountPaid, 0);
    expect(sale.totalAmount, 150000); // tout à crédit
  });
}
