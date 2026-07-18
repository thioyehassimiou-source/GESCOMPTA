import '../../../core/domain/payment_method.dart';

/// Saisie d'un remboursement de crédit par un client.
class RepaymentDraft {
  const RepaymentDraft({
    required this.customerId,
    required this.amount,
    this.method = PaymentMethod.cash,
    this.date,
  });

  final String customerId;

  /// Montant remboursé (GNF).
  final int amount;

  /// Moyen de règlement reçu (jamais `credit`).
  final PaymentMethod method;

  /// Date du règlement ; `null` ⇒ maintenant.
  final DateTime? date;
}

/// Résultat métier d'un remboursement enregistré.
class RecordedRepayment {
  const RecordedRepayment({
    required this.customerId,
    required this.amountApplied,
    required this.remainingBalance,
  });

  final String customerId;
  final int amountApplied;

  /// Reste dû par le client après ce règlement.
  final int remainingBalance;
}
