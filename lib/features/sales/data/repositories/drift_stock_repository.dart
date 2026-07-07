import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/tables/stock.dart';
import '../../domain/repositories/stock_repository.dart';

/// Implémentation Drift de [StockRepository].
///
/// Chaque sortie est tracée par un mouvement de stock immuable ; la quantité
/// du produit est mise à jour dans le même lot (batch) pour limiter les écritures.
class DriftStockRepository implements StockRepository {
  DriftStockRepository(this._db, {String Function()? idGenerator})
      : _newId = idGenerator ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final String Function() _newId;

  @override
  Future<void> applySaleExits(List<StockExit> exits) async {
    if (exits.isEmpty) return;

    await _db.batch((b) {
      for (final e in exits) {
        b.insert(
          _db.stockMovements,
          StockMovementsCompanion.insert(
            id: _newId(),
            productId: e.productId,
            type: StockMovementType.sale,
            quantity: -e.quantity, // sortie ⇒ quantité négative
            unitCost: Value(e.unitCost),
            sourceReference: Value(e.saleReference),
            date: Value(e.date),
          ),
        );
        b.update(
          _db.products,
          ProductsCompanion(stockQuantity: Value(e.newStockQuantity)),
          where: (t) => t.id.equals(e.productId),
        );
      }
    });
  }
}
