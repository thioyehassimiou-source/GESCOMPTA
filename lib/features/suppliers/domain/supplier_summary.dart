/// Résumé d'un fournisseur, utilisé pour l'écran principal des fournisseurs.
class SupplierSummary {
  const SupplierSummary({
    required this.supplierId,
    required this.supplierName,
    this.supplierPhone,
    required this.balance,
    required this.purchasesCount,
    required this.lastPurchaseDate,
  });

  final String supplierId;
  final String supplierName;
  final String? supplierPhone;

  /// Montant total que l'entreprise doit à ce fournisseur (GNF).
  final int balance;

  /// Nombre d'achats non soldés (à crédit).
  final int purchasesCount;

  /// Date du dernier achat à crédit.
  final DateTime lastPurchaseDate;
}
