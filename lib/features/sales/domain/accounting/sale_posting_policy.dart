import '../../../../core/domain/payment_method.dart';
import 'journal_draft.dart';

/// Données nécessaires pour comptabiliser une vente, sans référence à Drift.
class SalePostingContext {
  const SalePostingContext({
    required this.saleId,
    required this.saleReference,
    required this.date,
    required this.revenueTotal,
    required this.tenders,
    required this.creditAmount,
    required this.costOfGoodsSold,
  });

  final String saleId;
  final String saleReference;
  final DateTime date;

  /// Chiffre d'affaires de la vente (GNF) — crédité au compte de ventes.
  final int revenueTotal;

  /// Encaissements immédiats par moyen de règlement.
  final Map<PaymentMethod, int> tenders;

  /// Part restant à crédit (GNF) — 0 si tout est payé.
  final int creditAmount;

  /// Coût des marchandises vendues au CMP (GNF) — sortie de stock.
  final int costOfGoodsSold;
}

/// Règle de comptabilisation d'une vente.
///
/// Point d'extension central : une future variante (TVA, remises, ventes
/// multi-taux…) sera une nouvelle implémentation injectée, sans toucher au
/// moteur ni aux repositories.
abstract interface class SalePostingPolicy {
  /// Construit les pièces comptables équilibrées d'une vente.
  List<JournalEntryDraft> buildEntries(SalePostingContext context);
}
