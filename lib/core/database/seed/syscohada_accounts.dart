/// Plan comptable SYSCOHADA révisé — sous-ensemble adapté à un petit commerce.
///
/// Ce n'est pas le plan complet : il couvre les comptes réellement mouvementés
/// par le noyau (ventes, achats, stock, trésorerie, créances, dettes). Il pourra
/// être étendu compte par compte selon les besoins.
///
/// ⚠️ À faire valider par un comptable / expert SYSCOHADA avant commercialisation
/// (cf. risque « Fiabilité juridique de la comptabilité générée » du cahier des charges).
library;

/// Un compte du plan comptable prêt à être inséré.
class SeedAccount {
  const SeedAccount(this.code, this.label, {this.isHeader = false});

  final String code;
  final String label;
  final bool isHeader;

  int get accountClass => int.parse(code[0]);
}

const List<SeedAccount> kSyscohadaSeedAccounts = [
  // ── Classe 1 : Comptes de ressources durables ──
  SeedAccount('10', 'Capital', isHeader: true),
  SeedAccount('101', 'Capital social / individuel'),
  SeedAccount('12', 'Report à nouveau', isHeader: true),
  SeedAccount('121', 'Report à nouveau créditeur'),
  SeedAccount('129', 'Report à nouveau débiteur'),
  SeedAccount('13', 'Résultat net de l’exercice', isHeader: true),
  SeedAccount('131', 'Résultat net : bénéfice'),
  SeedAccount('139', 'Résultat net : perte'),

  // ── Classe 2 : Comptes d'actif immobilisé ──
  SeedAccount('24', 'Matériel, mobilier et actifs biologiques', isHeader: true),
  SeedAccount('2441', 'Matériel de bureau'),
  SeedAccount('2442', 'Matériel informatique'),

  // ── Classe 3 : Comptes de stocks ──
  SeedAccount('31', 'Marchandises', isHeader: true),
  SeedAccount('311', 'Marchandises (stock)'),

  // ── Classe 4 : Comptes de tiers ──
  SeedAccount('40', 'Fournisseurs et comptes rattachés', isHeader: true),
  SeedAccount('401', 'Fournisseurs, dettes en compte'),
  SeedAccount('41', 'Clients et comptes rattachés', isHeader: true),
  SeedAccount('411', 'Clients'),
  SeedAccount('44', 'État et collectivités publiques', isHeader: true),
  SeedAccount('4431', 'État, TVA facturée sur ventes'),
  SeedAccount('4452', 'État, TVA récupérable sur achats'),
  SeedAccount('47', 'Débiteurs et créditeurs divers', isHeader: true),
  SeedAccount('471', 'Compte d’attente'),

  // ── Classe 5 : Comptes de trésorerie ──
  SeedAccount('52', 'Banques', isHeader: true),
  SeedAccount('521', 'Banques locales'),
  SeedAccount('55', 'Instruments de monnaie électronique', isHeader: true),
  SeedAccount('551', 'Mobile money'),
  SeedAccount('57', 'Caisse', isHeader: true),
  SeedAccount('571', 'Caisse siège social'),

  // ── Classe 6 : Comptes de charges ──
  SeedAccount('60', 'Achats et variations de stocks', isHeader: true),
  SeedAccount('601', 'Achats de marchandises'),
  SeedAccount('6031', 'Variation des stocks de marchandises'),
  SeedAccount('61', 'Transports', isHeader: true),
  SeedAccount('611', 'Transports sur achats'),
  SeedAccount('62', 'Services extérieurs A', isHeader: true),
  SeedAccount('622', 'Locations et charges locatives'),
  SeedAccount('627', 'Frais de télécommunications'),
  SeedAccount('63', 'Services extérieurs B', isHeader: true),
  SeedAccount('64', 'Impôts et taxes', isHeader: true),
  SeedAccount('641', 'Impôts et taxes directs'),
  SeedAccount('66', 'Charges de personnel', isHeader: true),
  SeedAccount('661', 'Rémunérations directes versées au personnel'),

  // ── Classe 7 : Comptes de produits ──
  SeedAccount('70', 'Ventes', isHeader: true),
  SeedAccount('701', 'Ventes de marchandises'),
  SeedAccount('707', 'Produits accessoires'),
];
