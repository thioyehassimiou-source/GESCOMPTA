import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';

/// Présence de données métier (produits ou ventes) en base, lue une fois au
/// démarrage (`main.dart`) pour un accès synchrone par le routeur et l'accueil.
///
/// Sert à distinguer une **vraie première utilisation** (base vide) d'une
/// **boutique existante** dont le compte/la config auraient disparu : dans ce
/// second cas, on propose « Reprendre ma boutique » plutôt que de forcer une
/// création.
final businessDataExistsProvider =
    NotifierProvider<BusinessDataExistsNotifier, bool>(
      BusinessDataExistsNotifier.new,
    );

class BusinessDataExistsNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  // ignore: avoid_positional_boolean_parameters
  void set(bool exists) => state = exists;
}

/// Décompte des données existantes (produits, ventes), pour rassurer le
/// commerçant sur l'écran de reprise : « X produits, Y ventes retrouvés ».
final orphanDataCountsProvider =
    FutureProvider<({int products, int sales})>((ref) async {
      final db = ref.watch(databaseProvider);
      final products = await db.products.count().getSingle();
      final sales = await db.sales.count().getSingle();
      return (products: products, sales: sales);
    });
