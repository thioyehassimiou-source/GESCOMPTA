import '../entities/product_draft.dart';
import '../errors.dart';
import '../repositories/product_catalog_repository.dart';
import 'save_product_result.dart';

/// Met à jour la fiche d'un produit existant.
///
/// **Règles métier appliquées :**
/// * [RULE-020] Nom de produit obligatoire.
/// * [RULE-021] Prix d'achat et de vente non négatifs.
/// * [RULE-022] Quantité en stock non négative.
/// * [RULE-023] Seuil d'alerte non négatif.
///
/// N'ajuste pas le coût moyen pondéré : une correction de stock passera par le
/// futur module d'ajustement dédié.
class UpdateProductUseCase {
  const UpdateProductUseCase(this._repository);

  final ProductCatalogRepository _repository;

  Future<SaveProductResult> call(String id, ProductDraft draft) async {
    final error = draft.validate();
    if (error != null) return SaveProductFailure(error);

    try {
      await _repository.update(id, draft);
      return const SaveProductSuccess();
    } catch (e) {
      return SaveProductFailure(UnexpectedProductError(e.toString()));
    }
  }
}
