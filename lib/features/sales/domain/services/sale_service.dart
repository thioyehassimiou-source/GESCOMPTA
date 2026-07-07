import '../entities/recorded_sale.dart';
import '../entities/sale_draft.dart';

/// Contrat du moteur de vente : enregistrer une vente de bout en bout,
/// de manière **atomique**.
///
/// L'implémentation (couche data) exécute toutes les étapes — contrôle du
/// stock, décrément, mouvements, paiement, écritures SYSCOHADA — dans une
/// unique transaction. En cas d'échec, elle lève une `SaleDomainException`
/// et garantit un rollback complet.
abstract interface class SaleService {
  Future<RecordedSale> record(SaleDraft draft);
}
