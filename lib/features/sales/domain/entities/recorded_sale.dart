import '../../../../core/domain/payment_method.dart';

/// Résultat métier d'une vente enregistrée avec succès.
///
/// Type pur : ne contient aucune notion comptable exposée au commerçant.
class RecordedSale {
  const RecordedSale({
    required this.saleId,
    required this.reference,
    required this.date,
    required this.total,
    required this.amountPaid,
    required this.creditAmount,
    required this.profit,
    required this.dominantMethod,
  });

  final String saleId;
  final String reference;
  final DateTime date;

  /// Total de la vente (GNF).
  final int total;

  /// Encaissé immédiatement (GNF).
  final int amountPaid;

  /// Reste à crédit (GNF) — 0 si tout est payé.
  final int creditAmount;

  /// Bénéfice estimé = total − coût des marchandises (GNF).
  final int profit;

  /// Mode de règlement dominant, pour l'affichage récapitulatif.
  final PaymentMethod dominantMethod;

  bool get isCredit => creditAmount > 0;
}
