/// Une vente récente, données pures (aucun widget). L'icône d'affichage est
/// décidée par la présentation.
class RecentSale {
  const RecentSale({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.paid,
  });

  final String title;
  final String subtitle;
  final DateTime date;
  final int amount;
  final bool paid;
}

/// Produit sous son seuil d'alerte, réduit à ce qu'affiche l'accueil.
class LowStockItem {
  const LowStockItem({
    required this.name,
    required this.unit,
    required this.stockQuantity,
  });

  final String name;
  final String unit;
  final double stockQuantity;
}

/// Agrégats de l'écran Accueil, calculés côté SQL (aucune table n'est chargée
/// entièrement en mémoire). Les variations en % sont dérivées dans la couche
/// application à partir des valeurs courante / précédente.
class DashboardSnapshot {
  const DashboardSnapshot({
    required this.todaySales,
    required this.yesterdaySales,
    required this.todayProfit,
    required this.yesterdayProfit,
    required this.thisWeekSales,
    required this.prevWeekSales,
    required this.owed,
    required this.owedCount,
    required this.cashAvailable,
    required this.lowStock,
    required this.recentSales,
  });

  final int todaySales;
  final int yesterdaySales;
  final int todayProfit;
  final int yesterdayProfit;
  final int thisWeekSales;
  final int prevWeekSales;

  /// Total restant dû sur toutes les ventes (créances).
  final int owed;

  /// Nombre de ventes partiellement ou non réglées.
  final int owedCount;

  /// Solde des comptes de trésorerie (classe 5).
  final int cashAvailable;

  /// Produits actifs sous le seuil d'alerte, du plus bas au plus haut.
  final List<LowStockItem> lowStock;

  /// Cinq ventes les plus récentes.
  final List<RecentSale> recentSales;
}
