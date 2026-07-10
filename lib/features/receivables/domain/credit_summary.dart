/// Résumé de crédit d'un client — langage commerçant pur.
/// Répond à : « Qui me doit combien ? »
class CreditSummary {
  const CreditSummary({
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.balance,
    required this.salesCount,
    required this.lastSaleDate,
  });

  final String customerId;
  final String customerName;
  final String? customerPhone;

  /// Reste dû = Σ(total_amount − amount_paid) pour toutes les ventes ouvertes.
  final int balance;

  /// Nombre de ventes à crédit encore non soldées.
  final int salesCount;

  final DateTime lastSaleDate;
}
