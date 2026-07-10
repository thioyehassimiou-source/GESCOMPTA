import '../entities/product_draft.dart';
import '../errors.dart';
import '../repositories/product_catalog_repository.dart';
import 'save_product_result.dart';

/// Ajoute un nouveau produit au catalogue.
///
/// **Règles métier appliquées :**
/// * [RULE-020] Nom de produit obligatoire.
/// * [RULE-021] Prix d'achat et de vente non négatifs.
/// * [RULE-022] Quantité en stock non négative.
/// * [RULE-023] Seuil d'alerte non négatif.
///
/// Valide la saisie hors-base puis délègue la création au repository. Toute
/// issue est traduite en [SaveProductResult].
class AddProductUseCase {
  const AddProductUseCase(this._repository);

  final ProductCatalogRepository _repository;

  Future<SaveProductResult> call(ProductDraft draft) async {
    final error = draft.validate();
    if (error != null) return SaveProductFailure(error);

    try {
      await _repository.create(draft);
      return const SaveProductSuccess();
    } catch (e) {
      return SaveProductFailure(UnexpectedProductError(e.toString()));
    }
  }
}
