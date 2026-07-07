import 'package:drift/drift.dart';

import 'products.dart';

/// Nature d'un mouvement de stock.
enum StockMovementType {
  /// Entrée : approvisionnement / achat fournisseur.
  purchase,

  /// Sortie : vente.
  sale,

  /// Ajustement d'inventaire (correction, casse, péremption…).
  adjustment,
}

/// Historique des entrées / sorties de stock.
///
/// Chaque mouvement est immuable : la quantité en stock d'un produit est
/// le cumul de ses mouvements, ce qui garantit une piste d'audit fiable.
class StockMovements extends Table {
  @override
  String get tableName => 'stock_movements';

  TextColumn get id => text()();

  TextColumn get productId => text().references(Products, #id)();

  IntColumn get type => intEnum<StockMovementType>()();

  /// Quantité du mouvement : positive pour une entrée, négative pour une sortie.
  RealColumn get quantity => real()();

  /// Coût unitaire du mouvement (GNF) — utilisé pour recalculer le CMP.
  RealColumn get unitCost => real().withDefault(const Constant(0))();

  /// Référence de la pièce d'origine (vente, achat…).
  TextColumn get sourceReference => text().nullable()();

  TextColumn get reason => text().nullable()();

  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
