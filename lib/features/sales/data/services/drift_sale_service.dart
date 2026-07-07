import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/domain/payment_method.dart';
import '../../domain/accounting/sale_posting_policy.dart';
import '../../domain/entities/recorded_sale.dart';
import '../../domain/entities/sale_draft.dart';
import '../../domain/errors.dart';
import '../../domain/repositories/accounting_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/services/sale_service.dart';

/// Implémentation Drift du moteur de vente.
///
/// Exécute l'intégralité du workflow dans **une seule** transaction :
/// contrôle du stock → coûts (CMP) → création de la vente et de ses lignes →
/// sortie de stock → écritures SYSCOHADA. Toute exception provoque un
/// ROLLBACK complet — aucune donnée partielle ne subsiste.
class DriftSaleService implements SaleService {
  DriftSaleService({
    required AppDatabase db,
    required ProductRepository products,
    required StockRepository stock,
    required SaleRepository sales,
    required AccountingRepository accounting,
    required SalePostingPolicy postingPolicy,
    String Function()? idGenerator,
    DateTime Function()? clock,
  })  : _db = db,
        _products = products,
        _stock = stock,
        _sales = sales,
        _accounting = accounting,
        _policy = postingPolicy,
        _newId = idGenerator ?? (() => const Uuid().v4()),
        _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final ProductRepository _products;
  final StockRepository _stock;
  final SaleRepository _sales;
  final AccountingRepository _accounting;
  final SalePostingPolicy _policy;
  final String Function() _newId;
  final DateTime Function() _now;

  @override
  Future<RecordedSale> record(SaleDraft draft) {
    return _db.transaction(() async {
      final date = draft.date ?? _now();

      // ── 1-2. Charger les produits (1 requête) et contrôler le stock ──
      final snapshots =
          await _products.findByIds(draft.lines.map((l) => l.productId));

      // Cumuler les quantités par produit (un produit peut apparaître sur
      // plusieurs lignes : le contrôle porte sur le total demandé).
      final requestedByProduct = <String, double>{};
      for (final line in draft.lines) {
        requestedByProduct.update(
          line.productId,
          (q) => q + line.quantity,
          ifAbsent: () => line.quantity,
        );
      }

      requestedByProduct.forEach((productId, requested) {
        final snap = snapshots[productId];
        if (snap == null) {
          throw SaleDomainException(ProductNotFoundError(productId));
        }
        if (snap.stockQuantity < requested) {
          throw SaleDomainException(InsufficientStockError(
            productLabel: snap.name,
            available: snap.stockQuantity,
            requested: requested,
            unit: snap.unit,
          ));
        }
      });

      // ── 3-4. Coûts (CMP), lignes, total, marge ──
      final saleId = _newId();
      final reference = await _sales.nextReference(date);

      var costOfGoods = 0;
      final newLines = <NewSaleLine>[];
      for (final line in draft.lines) {
        final snap = snapshots[line.productId]!;
        costOfGoods += (snap.weightedAverageCost * line.quantity).round();
        newLines.add(NewSaleLine(
          id: _newId(),
          saleId: saleId,
          productId: line.productId,
          label: snap.name,
          quantity: line.quantity,
          unitPrice: line.unitPrice,
          unitCost: snap.weightedAverageCost,
          lineTotal: line.lineTotal,
        ));
      }

      final total = draft.total;
      final amountPaid = draft.paidImmediately;
      final creditAmount = draft.creditAmount;
      final dominant = _dominantMethod(draft);

      // ── 5-6. Créer la vente + ses lignes ──
      await _sales.createSale(NewSaleData(
        id: saleId,
        reference: reference,
        customerId: draft.customerId,
        date: date,
        total: total,
        amountPaid: amountPaid,
        paymentMethod: dominant,
        note: draft.note,
      ));
      await _sales.addLines(newLines);

      // ── 7-8. Décrément du stock + mouvements ──
      final exits = <StockExit>[];
      requestedByProduct.forEach((productId, requested) {
        final snap = snapshots[productId]!;
        exits.add(StockExit(
          productId: productId,
          quantity: requested,
          unitCost: snap.weightedAverageCost,
          newStockQuantity: snap.stockQuantity - requested,
          saleReference: reference,
          date: date,
        ));
      });
      await _stock.applySaleExits(exits);

      // ── 9-10. Écritures SYSCOHADA (règlement + sortie de stock) ──
      final entries = _policy.buildEntries(SalePostingContext(
        saleId: saleId,
        saleReference: reference,
        date: date,
        revenueTotal: total,
        tenders: draft.tendersByMethod,
        creditAmount: creditAmount,
        costOfGoodsSold: costOfGoods,
      ));
      for (final entry in entries) {
        await _accounting.postEntry(entry);
      }

      // ── 12. Résultat métier (le commerçant ne verra que « ✅ ») ──
      return RecordedSale(
        saleId: saleId,
        reference: reference,
        date: date,
        total: total,
        amountPaid: amountPaid,
        creditAmount: creditAmount,
        profit: total - costOfGoods,
        dominantMethod: dominant,
      );
    });
  }

  /// Mode de règlement le plus représentatif, pour l'affichage récapitulatif.
  /// Sans aucun règlement immédiat, la vente est intégralement à crédit.
  PaymentMethod _dominantMethod(SaleDraft draft) {
    if (draft.tenders.isEmpty) return PaymentMethod.credit;
    var best = draft.tenders.first;
    for (final t in draft.tenders) {
      if (t.amount > best.amount) best = t;
    }
    return best.method;
  }
}
