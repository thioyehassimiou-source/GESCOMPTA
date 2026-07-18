import '../../../sales/domain/accounting/journal_draft.dart';
import '../../../sales/domain/accounting/syscohada_accounts.dart';
import 'repayment_posting_policy.dart';

/// Comptabilisation SYSCOHADA d'un remboursement de crédit : le client règle une
/// partie de sa dette. Une pièce équilibrée :
///  - débit trésorerie (571/551/521) : l'argent entre ;
///  - crédit 411 (clients) : la créance diminue.
class SyscohadaRepaymentPostingPolicy implements RepaymentPostingPolicy {
  const SyscohadaRepaymentPostingPolicy();

  @override
  JournalEntryDraft buildEntry(RepaymentPostingContext c) {
    return JournalEntryDraft(
      date: c.date,
      description: 'Règlement crédit — ${c.customerName}',
      source: AccountingSource.creditPayment,
      sourceId: null,
      lines: [
        JournalLineDraft.debit(
          SyscohadaAccounts.forTender(c.method),
          'Règlement reçu — ${c.customerName}',
          c.amount,
        ),
        JournalLineDraft.credit(
          SyscohadaAccounts.clients,
          'Diminution de la créance — ${c.customerName}',
          c.amount,
        ),
      ],
    );
  }
}
