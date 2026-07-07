import 'package:drift/drift.dart';

/// Fiche produit — noyau commun à tous les secteurs.
///
/// Les champs sectoriels (péremption, lot, DCI, variantes…) seront ajoutés
/// dans des tables satellites lors de l'activation des modules sectoriels.
class Products extends Table {
  @override
  String get tableName => 'products';

  TextColumn get id => text()();

  /// Nom commercial du produit.
  TextColumn get name => text().withLength(min: 1, max: 200)();

  /// Référence / code interne (facultatif).
  TextColumn get reference => text().nullable()();

  /// Unité de vente : pièce, kg, m, litre, coupon…
  TextColumn get unit => text().withDefault(const Constant('pièce'))();

  /// Prix d'achat unitaire (GNF, sans décimales — le GNF n'a pas de subdivision usuelle).
  IntColumn get purchasePrice => integer().withDefault(const Constant(0))();

  /// Prix de vente unitaire (GNF).
  IntColumn get salePrice => integer().withDefault(const Constant(0))();

  /// Quantité actuellement en stock (peut être fractionnaire pour le vrac).
  RealColumn get stockQuantity => real().withDefault(const Constant(0))();

  /// Seuil d'alerte de stock faible.
  RealColumn get lowStockThreshold => real().withDefault(const Constant(0))();

  /// Coût moyen pondéré courant (GNF) — base de valorisation SYSCOHADA.
  RealColumn get weightedAverageCost => real().withDefault(const Constant(0))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
