import '../supplier_summary.dart';

abstract interface class SuppliersRepository {
  /// Flux réactif des fournisseurs envers qui nous avons une dette, triés du plus
  /// gros créancier au plus petit.
  Stream<List<SupplierSummary>> watchSupplierSummaries();

  /// Récupère l'historique des paiements effectués à un fournisseur.
  Future<List<SupplierPaymentHistoryItem>> getPaymentHistory(String supplierId);

  /// Flux réactif des achats récents (tous fournisseurs confondus).
  Stream<List<RecentPurchaseView>> watchRecentPurchases();
}

class SupplierPaymentHistoryItem {
  const SupplierPaymentHistoryItem({required this.amount, required this.date});

  final int amount;
  final DateTime date;
}

class RecentPurchaseView {
  const RecentPurchaseView({
    required this.purchaseId,
    required this.supplierName,
    required this.date,
    required this.totalAmount,
    required this.amountPaid,
    required this.isCancelled,
  });

  final String purchaseId;
  final String supplierName;
  final DateTime date;
  final int totalAmount;
  final int amountPaid;
  final bool isCancelled;

  bool get isPaid => amountPaid >= totalAmount;
}
