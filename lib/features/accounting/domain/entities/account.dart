/// Compte du plan comptable SYSCOHADA, vue métier découplée de Drift.
class Account {
  const Account({
    required this.code,
    required this.label,
    required this.accountClass,
    required this.isHeader,
  });

  /// Numéro de compte SYSCOHADA (ex. 411, 701, 601…).
  final String code;

  final String label;

  /// Classe SYSCOHADA (1 à 8), déduite du premier chiffre du code.
  final int accountClass;

  /// true pour un compte de regroupement (non mouvementable directement).
  final bool isHeader;
}
