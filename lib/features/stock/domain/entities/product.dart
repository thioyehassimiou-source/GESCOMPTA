/// Fiche produit du catalogue, vue métier découplée de Drift.
///
/// La couche data mappe la ligne Drift `Product` vers cette entité ; aucune
/// couche au-dessus de `data/` ne connaît le type généré par Drift.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.reference,
    required this.unit,
    required this.purchasePrice,
    required this.salePrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    required this.weightedAverageCost,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// Référence / code interne (facultatif).
  final String? reference;

  /// Unité de vente : pièce, kg, litre…
  final String unit;

  /// Prix d'achat unitaire (GNF).
  final int purchasePrice;

  /// Prix de vente unitaire (GNF).
  final int salePrice;

  /// Quantité actuellement en stock (fractionnaire possible pour le vrac).
  final double stockQuantity;

  /// Seuil d'alerte de stock faible.
  final double lowStockThreshold;

  /// Coût moyen pondéré courant (GNF) — base de valorisation SYSCOHADA,
  /// jamais montré au commerçant.
  final double weightedAverageCost;

  final bool isActive;
  final DateTime createdAt;
}
