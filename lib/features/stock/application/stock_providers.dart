import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../data/repositories/drift_product_catalog_repository.dart';
import '../domain/entities/product.dart';
import '../domain/repositories/product_catalog_repository.dart';
import '../domain/usecases/add_product.dart';
import '../domain/usecases/update_product.dart';

/// Câblage Riverpod du catalogue produits.

final productCatalogRepositoryProvider = Provider<ProductCatalogRepository>(
  (ref) => DriftProductCatalogRepository(ref.watch(databaseProvider)),
);

final addProductUseCaseProvider = Provider<AddProductUseCase>(
  (ref) => AddProductUseCase(ref.watch(productCatalogRepositoryProvider)),
);

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>(
  (ref) => UpdateProductUseCase(ref.watch(productCatalogRepositoryProvider)),
);

/// Flux réactif de la liste des produits, exposé à la présentation.
final productsStreamProvider = StreamProvider<List<Product>>(
  (ref) => ref.watch(productCatalogRepositoryProvider).watchAll(),
);
