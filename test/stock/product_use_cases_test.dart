import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gescompta/core/database/database.dart';
import 'package:gescompta/features/stock/data/repositories/drift_product_catalog_repository.dart';
import 'package:gescompta/features/stock/domain/entities/product_draft.dart';
import 'package:gescompta/features/stock/domain/errors.dart';
import 'package:gescompta/features/stock/domain/usecases/add_product.dart';
import 'package:gescompta/features/stock/domain/usecases/save_product_result.dart';
import 'package:gescompta/features/stock/domain/usecases/update_product.dart';

void main() {
  late AppDatabase db;
  late DriftProductCatalogRepository repo;
  late AddProductUseCase addProduct;
  late UpdateProductUseCase updateProduct;

  ProductDraft draft({
    String name = 'Riz',
    int purchasePrice = 8000,
    int salePrice = 10000,
    double stockQuantity = 25,
    double lowStockThreshold = 5,
  }) =>
      ProductDraft(
        name: name,
        reference: 'R-01',
        unit: 'kg',
        purchasePrice: purchasePrice,
        salePrice: salePrice,
        stockQuantity: stockQuantity,
        lowStockThreshold: lowStockThreshold,
      );

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftProductCatalogRepository(db, idGenerator: () => 'fixed-id');
    addProduct = AddProductUseCase(repo);
    updateProduct = UpdateProductUseCase(repo);
  });

  tearDown(() async => db.close());

  test('AddProductUseCase crée le produit et aligne le CMP sur le prix d\'achat',
      () async {
    final result = await addProduct(draft(purchasePrice: 8000));

    expect(result, isA<SaveProductSuccess>());
    final products = await repo.watchAll().first;
    expect(products, hasLength(1));
    expect(products.single.name, 'Riz');
    expect(products.single.weightedAverageCost, 8000);
  });

  test('AddProductUseCase refuse un nom vide', () async {
    final result = await addProduct(draft(name: '   '));

    expect(result, isA<SaveProductFailure>());
    expect((result as SaveProductFailure).error,
        isA<MissingProductNameError>());
    expect(await repo.watchAll().first, isEmpty);
  });

  test('AddProductUseCase refuse un prix négatif', () async {
    final result = await addProduct(draft(salePrice: -1));

    expect(result, isA<SaveProductFailure>());
    expect((result as SaveProductFailure).error, isA<NegativePriceError>());
  });

  test('UpdateProductUseCase modifie la fiche sans altérer le CMP', () async {
    await addProduct(draft(purchasePrice: 8000));

    final result = await updateProduct('fixed-id',
        draft(name: 'Riz parfumé', purchasePrice: 20000, salePrice: 25000));

    expect(result, isA<SaveProductSuccess>());
    final product = (await repo.watchAll().first).single;
    expect(product.name, 'Riz parfumé');
    expect(product.salePrice, 25000);
    // Le CMP reste celui de la création : une simple édition ne le recalcule pas.
    expect(product.weightedAverageCost, 8000);
  });
}
