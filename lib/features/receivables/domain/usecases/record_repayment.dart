import '../../../../core/domain/payment_method.dart';
import '../errors.dart';
import '../repayment_draft.dart';
import '../services/repayment_service.dart';

/// Résultat typé d'un remboursement (aucune exception ne fuit vers l'UI).
sealed class RecordRepaymentResult {
  const RecordRepaymentResult();
}

class RecordRepaymentSuccess extends RecordRepaymentResult {
  const RecordRepaymentSuccess(this.repayment);
  final RecordedRepayment repayment;
}

class RecordRepaymentFailure extends RecordRepaymentResult {
  const RecordRepaymentFailure(this.error);
  final RepaymentError error;
}

/// Enregistre le remboursement (partiel ou total) d'un client.
///
/// **Règles métier appliquées :**
/// * [RULE-040] Montant strictement positif.
/// * [RULE-041] Moyen de paiement reçu (jamais « crédit »).
/// * [RULE-042] Montant ≤ dette en cours du client (vérifié en base).
/// * [RULE-030] Équilibre de la pièce comptable (garde-fou du service).
class RecordRepaymentUseCase {
  const RecordRepaymentUseCase(this._service);

  final RepaymentService _service;

  Future<RecordRepaymentResult> call(RepaymentDraft draft) async {
    if (draft.amount <= 0) {
      return const RecordRepaymentFailure(InvalidRepaymentAmountError());
    }
    if (draft.method == PaymentMethod.credit) {
      return const RecordRepaymentFailure(InvalidRepaymentMethodError());
    }

    try {
      final recorded = await _service.record(draft);
      return RecordRepaymentSuccess(recorded);
    } on RepaymentDomainException catch (e) {
      return RecordRepaymentFailure(e.error);
    } catch (e) {
      return RecordRepaymentFailure(UnexpectedRepaymentError(e.toString()));
    }
  }
}
