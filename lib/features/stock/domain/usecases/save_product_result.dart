import '../errors.dart';

/// Résultat typé de l'enregistrement d'un produit (jamais d'exception qui fuit
/// vers l'UI).
sealed class SaveProductResult {
  const SaveProductResult();
}

/// Le produit a été créé ou mis à jour avec succès.
class SaveProductSuccess extends SaveProductResult {
  const SaveProductSuccess();
}

/// L'enregistrement a échoué ; [error] porte un message montrable au commerçant.
class SaveProductFailure extends SaveProductResult {
  const SaveProductFailure(this.error);
  final ProductError error;
}
