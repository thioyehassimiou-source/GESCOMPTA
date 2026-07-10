/// Résumé du commerce en langage simple. Aucune notion comptable :
/// pas de balance, pas de comptes, pas de débit/crédit.
class BusinessSummary {
  const BusinessSummary({
    required this.monthSales,
    required this.monthProfit,
    required this.owedToMe,
    required this.cashCollectedThisMonth,
  });

  /// Ventes du mois (GNF).
  final int monthSales;

  /// Bénéfice estimé du mois (GNF).
  final int monthProfit;

  /// Ce que les clients me doivent, toutes ventes confondues (GNF).
  final int owedToMe;

  /// Argent réellement encaissé ce mois (GNF).
  final int cashCollectedThisMonth;
}
