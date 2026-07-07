/// Mode de règlement d'une opération, exprimé en langage commerçant.
///
/// Concept métier pur (aucune dépendance à la base). La couche data l'utilise
/// comme `intEnum` — l'ordre est donc figé : n'ajouter que des valeurs en fin.
enum PaymentMethod {
  /// Espèces (caisse).
  cash,

  /// Mobile Money (Orange Money, MTN…).
  mobileMoney,

  /// Vente à crédit (le client paiera plus tard).
  credit,

  /// Virement / dépôt bancaire.
  bank,
}

/// Moyens de règlement immédiat (hors crédit) : ce que le commerçant encaisse.
const kImmediateTenders = <PaymentMethod>[
  PaymentMethod.cash,
  PaymentMethod.mobileMoney,
  PaymentMethod.bank,
];
