import '../../../../core/database/database.dart';
import '../../domain/entities/product_snapshot.dart';
import '../../domain/repositories/product_repository.dart';

/// Implémentation Drift de [ProductRepository].
class DriftProductRepository implements ProductRepository {
  DriftProductRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Map<String, ProductSnapshot>> findByIds(Iterable<String> ids) async {
    final idList = ids.toSet().toList();
    if (idList.isEmpty) return const {};

    final rows = await (_db.select(_db.products)
          ..where((t) => t.id.isIn(idList)))
        .get();

    return {
      for (final p in rows)
        p.id: ProductSnapshot(
          id: p.id,
          name: p.name,
          unit: p.unit,
          salePrice: p.salePrice,
          stockQuantity: p.stockQuantity,
          weightedAverageCost: p.weightedAverageCost,
          isActive: p.isActive,
        ),
    };
  }
}
