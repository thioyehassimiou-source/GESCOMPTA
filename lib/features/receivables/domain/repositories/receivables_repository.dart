import '../credit_summary.dart';

/// Accès au cahier de crédit : qui doit combien.
abstract interface class ReceivablesRepository {
  /// Flux réactif des clients ayant un solde dû, du plus gros débiteur au plus
  /// petit. Un client sans reste dû n'apparaît pas.
  Stream<List<CreditSummary>> watchCreditSummaries();
}
