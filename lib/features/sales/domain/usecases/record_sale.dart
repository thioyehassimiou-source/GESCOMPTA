import '../entities/recorded_sale.dart';
import '../entities/sale_draft.dart';
import '../errors.dart';
import '../services/sale_service.dart';

/// Résultat typé de l'enregistrement d'une vente (jamais d'exception qui fuit
/// vers l'UI).
sealed class RecordSaleResult {
  const RecordSaleResult();
}

class RecordSaleSuccess extends RecordSaleResult {
  const RecordSaleSuccess(this.sale);
  final RecordedSale sale;
}

class RecordSaleFailure extends RecordSaleResult {
  const RecordSaleFailure(this.error);
  final SaleError error;
}

/// Cas d'usage « enregistrer une vente ».
///
/// Responsable des validations qui ne nécessitent pas la base (rapides, sans
/// I/O), puis délègue au [SaleService] pour l'exécution atomique. Traduit toute
/// issue en [RecordSaleResult].
class RecordSaleUseCase {
  const RecordSaleUseCase(this._service, {ProductLabelResolver? labelFor})
      : _labelFor = labelFor;

  final SaleService _service;

  /// Optionnel : fournit un libellé produit pour des messages plus parlants.
  final ProductLabelResolver? _labelFor;

  Future<RecordSaleResult> call(SaleDraft draft) async {
    final validation = _validate(draft);
    if (validation != null) return RecordSaleFailure(validation);

    try {
      final recorded = await _service.record(draft);
      return RecordSaleSuccess(recorded);
    } on SaleDomainException catch (e) {
      return RecordSaleFailure(e.error);
    } catch (e) {
      return RecordSaleFailure(UnexpectedSaleError(e.toString()));
    }
  }

  /// Validations pures (sans accès base). Retourne la première erreur trouvée,
  /// ou null si l'entrée est saine.
  SaleError? _validate(SaleDraft draft) {
    if (draft.lines.isEmpty) return const EmptySaleError();

    for (final line in draft.lines) {
      final label = _labelFor?.call(line.productId) ?? 'ce produit';
      if (line.quantity <= 0) return InvalidQuantityError(label);
      if (line.unitPrice < 0) return InvalidPriceError(label);
    }

    if (draft.paidImmediately > draft.total) {
      return OverpaymentError(total: draft.total, paid: draft.paidImmediately);
    }

    if (draft.creditAmount > 0 && draft.customerId == null) {
      return const CreditRequiresCustomerError();
    }

    return null;
  }
}

/// Résout un libellé produit à partir de son identifiant (pour les messages).
typedef ProductLabelResolver = String? Function(String productId);
