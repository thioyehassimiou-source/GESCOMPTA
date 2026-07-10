import '../entities/business_summary.dart';

/// Fournit le résumé « Mon commerce » du mois en cours.
abstract interface class BusinessSummaryRepository {
  /// Agrège le résumé à l'instant [now] (injecté pour la testabilité). Les
  /// sommes sont poussées en SQL — aucune table n'est chargée en entier.
  Future<BusinessSummary> load(DateTime now);
}
