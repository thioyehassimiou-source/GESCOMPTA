/// Erreurs métier du moteur de vente, formulées en langage commerçant.
/// Aucune fuite technique : ces messages sont montrables tels quels.
sealed class SaleError {
  const SaleError();

  /// Message prêt à afficher au commerçant.
  String get message;
}

/// Aucune ligne dans la vente.
class EmptySaleError extends SaleError {
  const EmptySaleError();
  @override
  String get message =>
      'Ajoutez au moins un produit avant d\'enregistrer la vente.';
}

/// Quantité nulle ou négative.
class InvalidQuantityError extends SaleError {
  const InvalidQuantityError(this.productLabel);
  final String productLabel;
  @override
  String get message =>
      'La quantité de « $productLabel » doit être supérieure à zéro.';
}

/// Prix unitaire négatif.
class InvalidPriceError extends SaleError {
  const InvalidPriceError(this.productLabel);
  final String productLabel;
  @override
  String get message => 'Le prix de « $productLabel » n\'est pas valide.';
}

/// Produit introuvable (supprimé entre la sélection et l'enregistrement).
class ProductNotFoundError extends SaleError {
  const ProductNotFoundError(this.productId);
  final String productId;
  @override
  String get message => 'Un produit sélectionné n\'existe plus.';
}

/// Stock insuffisant pour honorer la vente.
class InsufficientStockError extends SaleError {
  const InsufficientStockError({
    required this.productLabel,
    required this.available,
    required this.requested,
    required this.unit,
  });
  final String productLabel;
  final double available;
  final double requested;
  final String unit;

  @override
  String get message {
    String q(double v) =>
        v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return 'Stock insuffisant pour « $productLabel » : il reste '
        '${q(available)} $unit, vous en vendez ${q(requested)}.';
  }
}

/// Vente à crédit sans client identifié.
class CreditRequiresCustomerError extends SaleError {
  const CreditRequiresCustomerError();
  @override
  String get message =>
      'Pour une vente à crédit, choisissez d\'abord le client concerné.';
}

/// Le montant réglé dépasse le total de la vente.
class OverpaymentError extends SaleError {
  const OverpaymentError({required this.total, required this.paid});
  final int total;
  final int paid;
  @override
  String get message =>
      'Le montant payé dépasse le total de la vente. Vérifiez les montants.';
}

/// Erreur inattendue : la transaction a été annulée, rien n'a été enregistré.
class UnexpectedSaleError extends SaleError {
  const UnexpectedSaleError(this.detail);
  final String detail;
  @override
  String get message =>
      'Une erreur est survenue, la vente n\'a pas été enregistrée. '
      'Aucune donnée n\'a été modifiée.';
}

/// Garde-fou d'intégrité : une pièce comptable générée n'est pas équilibrée
/// (Σ débits ≠ Σ crédits). Ne devrait jamais survenir ; si c'est le cas, la
/// transaction est annulée pour ne jamais déséquilibrer les livres.
class UnbalancedEntryError extends SaleError {
  const UnbalancedEntryError({required this.totalDebit, required this.totalCredit});
  final int totalDebit;
  final int totalCredit;
  @override
  String get message =>
      'Une erreur est survenue, la vente n\'a pas été enregistrée. '
      'Aucune donnée n\'a été modifiée.';
}

/// Exception interne servant à déclencher le ROLLBACK de la transaction Drift.
/// Portée strictement au domaine ; le use-case la retraduit en [SaleError].
class SaleDomainException implements Exception {
  const SaleDomainException(this.error);
  final SaleError error;
  @override
  String toString() => 'SaleDomainException(${error.runtimeType})';
}
