import '../entities/dashboard_snapshot.dart';

/// Fournit les indicateurs agrégés de l'écran Accueil.
abstract interface class DashboardRepository {
  /// Agrège les indicateurs à l'instant [now] (injecté pour la testabilité).
  /// Toute la sommation est poussée en SQL — aucune table n'est chargée en
  /// entier en mémoire.
  Future<DashboardSnapshot> load(DateTime now);
}
