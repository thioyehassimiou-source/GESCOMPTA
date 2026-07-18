/// Erreurs métier du remboursement de crédit, en langage commerçant.
sealed class RepaymentError {
  const RepaymentError();
  String get message;
}

/// Montant nul ou négatif.
class InvalidRepaymentAmountError extends RepaymentError {
  const InvalidRepaymentAmountError();
  @override
  String get message =>
      'Le montant du remboursement doit être supérieur à zéro.';
}

/// Moyen de règlement « crédit » impossible pour un remboursement.
class InvalidRepaymentMethodError extends RepaymentError {
  const InvalidRepaymentMethodError();
  @override
  String get message =>
      'Choisissez un moyen de paiement reçu (espèces, mobile, banque).';
}

/// Le client n'a aucune dette en cours.
class NoOutstandingDebtError extends RepaymentError {
  const NoOutstandingDebtError();
  @override
  String get message => 'Ce client n\'a aucune dette en cours.';
}

/// Le montant dépasse ce que le client doit encore.
class ExceedsDebtError extends RepaymentError {
  const ExceedsDebtError(this.outstanding);

  /// Reste réellement dû (GNF).
  final int outstanding;

  @override
  String get message => 'Le montant dépasse la dette du client.';
}

/// Erreur inattendue : rien n'a été enregistré.
class UnexpectedRepaymentError extends RepaymentError {
  const UnexpectedRepaymentError(this.detail);
  final String detail;
  @override
  String get message =>
      'Une erreur est survenue, le remboursement n\'a pas été enregistré.';
}

/// Exception interne déclenchant le ROLLBACK de la transaction Drift.
class RepaymentDomainException implements Exception {
  const RepaymentDomainException(this.error);
  final RepaymentError error;
  @override
  String toString() => 'RepaymentDomainException(${error.runtimeType})';
}
