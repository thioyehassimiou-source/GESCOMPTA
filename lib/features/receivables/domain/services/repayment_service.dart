import '../repayment_draft.dart';

/// Enregistre un remboursement de crédit de façon atomique (règlements,
/// diminution des ventes dues et écriture comptable dans une seule transaction).
abstract interface class RepaymentService {
  Future<RecordedRepayment> record(RepaymentDraft draft);
}
