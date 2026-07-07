import '../entities/product_snapshot.dart';

/// Accès en lecture aux produits pour le moteur de vente.
abstract interface class ProductRepository {
  /// Charge les produits demandés en une seule requête.
  /// Les identifiants absents ne figurent pas dans la map retournée.
  Future<Map<String, ProductSnapshot>> findByIds(Iterable<String> ids);
}
