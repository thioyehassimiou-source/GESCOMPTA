import '../../../../core/domain/payment_method.dart';
import '../../../sales/domain/accounting/journal_draft.dart';

/// Données pour comptabiliser un remboursement de crédit.
class RepaymentPostingContext {
  const RepaymentPostingContext({
    required this.date,
    required this.amount,
    required this.method,
    required this.customerName,
  });

  final DateTime date;
  final int amount;
  final PaymentMethod method;
  final String customerName;
}

/// Règle de comptabilisation d'un remboursement de crédit.
abstract interface class RepaymentPostingPolicy {
  /// Construit la pièce comptable équilibrée du règlement.
  JournalEntryDraft buildEntry(RepaymentPostingContext context);
}
