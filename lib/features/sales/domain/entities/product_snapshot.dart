/// Vue métier d'un produit au moment de la vente, découplée de Drift.
///
/// Le moteur raisonne sur ce type pur ; la couche data mappe la ligne Drift
/// `Product` vers ce snapshot.
class ProductSnapshot {
  const ProductSnapshot({
    required this.id,
    required this.name,
    required this.unit,
    required this.salePrice,
    required this.stockQuantity,
    required this.weightedAverageCost,
    required this.isActive,
  });

  final String id;
  final String name;
  final String unit;

  /// Prix de vente unitaire conseillé (GNF).
  final int salePrice;

  /// Quantité actuellement en stock.
  final double stockQuantity;

  /// Coût moyen pondéré courant (GNF) — jamais montré au commerçant.
  final double weightedAverageCost;

  final bool isActive;
}
