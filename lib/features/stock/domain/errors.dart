/// Erreurs métier du catalogue produits, formulées en langage commerçant.
/// Aucune fuite technique : ces messages sont montrables tels quels.
sealed class ProductError {
  const ProductError();

  /// Message prêt à afficher au commerçant.
  String get message;
}

/// Nom de produit manquant.
class MissingProductNameError extends ProductError {
  const MissingProductNameError();
  @override
  String get message => 'Donnez un nom au produit avant d\'enregistrer.';
}

/// Prix d'achat ou de vente négatif.
class NegativePriceError extends ProductError {
  const NegativePriceError();
  @override
  String get message => 'Les prix ne peuvent pas être négatifs.';
}

/// Quantité en stock négative.
class NegativeStockError extends ProductError {
  const NegativeStockError();
  @override
  String get message => 'La quantité en stock ne peut pas être négative.';
}

/// Seuil d'alerte négatif.
class NegativeThresholdError extends ProductError {
  const NegativeThresholdError();
  @override
  String get message => 'Le seuil d\'alerte ne peut pas être négatif.';
}

/// Erreur inattendue : rien n'a été enregistré.
class UnexpectedProductError extends ProductError {
  const UnexpectedProductError(this.detail);
  final String detail;
  @override
  String get message =>
      'Une erreur est survenue, le produit n\'a pas été enregistré.';
}
