/// Échelle d'espacement de la charte (en pixels logiques).
/// À utiliser partout à la place de valeurs numériques en dur.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double base = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Largeur de la barre de navigation latérale.
  static const double navWidth = 72;

  /// Largeur maximale du contenu centré.
  static const double containerMax = 1280;

  /// Hauteur de la barre supérieure.
  static const double topBarHeight = 64;
}

/// Rayons d'arrondi de la charte.
abstract final class AppRadius {
  static const double sm = 4;
  static const double lg = 8;
  static const double xl = 12;
  static const double full = 9999;
}
