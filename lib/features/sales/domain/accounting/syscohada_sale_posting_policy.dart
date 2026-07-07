import 'journal_draft.dart';
import 'sale_posting_policy.dart';
import 'syscohada_accounts.dart';

/// Comptabilisation SYSCOHADA d'une vente de marchandises (sans TVA à ce stade).
///
/// Deux pièces équilibrées :
///  1. Vente : débit trésorerie/clients, crédit 701 (produits) = total.
///  2. Sortie de stock au coût : débit 6031, crédit 311 = coût des marchandises.
class SyscohadaSalePostingPolicy implements SalePostingPolicy {
  const SyscohadaSalePostingPolicy();

  @override
  List<JournalEntryDraft> buildEntries(SalePostingContext c) {
    final entries = <JournalEntryDraft>[];

    // ── Pièce 1 : la vente ──
    final saleLines = <JournalLineDraft>[];
    c.tenders.forEach((method, amount) {
      if (amount > 0) {
        saleLines.add(JournalLineDraft.debit(
          SyscohadaAccounts.forTender(method),
          'Vente ${c.saleReference}',
          amount,
        ));
      }
    });
    if (c.creditAmount > 0) {
      saleLines.add(JournalLineDraft.debit(
        SyscohadaAccounts.clients,
        'Vente à crédit ${c.saleReference}',
        c.creditAmount,
      ));
    }
    saleLines.add(JournalLineDraft.credit(
      SyscohadaAccounts.merchandiseSales,
      'Vente ${c.saleReference}',
      c.revenueTotal,
    ));
    entries.add(JournalEntryDraft(
      date: c.date,
      description: 'Vente ${c.saleReference}',
      source: AccountingSource.sale,
      sourceId: c.saleId,
      lines: saleLines,
    ));

    // ── Pièce 2 : sortie de stock au coût (uniquement si coût connu) ──
    if (c.costOfGoodsSold > 0) {
      entries.add(JournalEntryDraft(
        date: c.date,
        description: 'Sortie de stock ${c.saleReference}',
        source: AccountingSource.sale,
        sourceId: c.saleId,
        lines: [
          JournalLineDraft.debit(
            SyscohadaAccounts.stockVariation,
            'Coût des marchandises vendues',
            c.costOfGoodsSold,
          ),
          JournalLineDraft.credit(
            SyscohadaAccounts.merchandiseStock,
            'Sortie de stock',
            c.costOfGoodsSold,
          ),
        ],
      ));
    }

    return entries;
  }
}
