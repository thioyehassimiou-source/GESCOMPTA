/// Une sortie de stock consécutive à une vente.
class StockExit {
  const StockExit({
    required this.productId,
    required this.quantity,
    required this.unitCost,
    required this.newStockQuantity,
    required this.saleReference,
    required this.date,
  });

  final String productId;

  /// Quantité vendue (positive).
  final int quantity;

  /// Coût unitaire au CMP au moment de la sortie (GNF).
  final int unitCost;

  /// Nouvelle quantité en stock après la sortie (précalculée par le moteur).
  final int newStockQuantity;

  final String saleReference;
  final DateTime date;
}

/// Mise à jour du stock lors d'une vente.
abstract interface class StockRepository {
  /// Enregistre les mouvements de sortie et met à jour les quantités des
  /// produits concernés — en une seule opération groupée.
  Future<void> applySaleExits(List<StockExit> exits);
}
