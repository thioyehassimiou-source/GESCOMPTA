import 'package:drift/drift.dart';

/// Compte du plan comptable SYSCOHADA révisé.
class Accounts extends Table {
  @override
  String get tableName => 'accounts';

  /// Numéro de compte SYSCOHADA (ex. 411, 701, 601…).
  TextColumn get code => text()();

  TextColumn get label => text()();

  /// Classe SYSCOHADA (1 à 8), déduite du premier chiffre du code.
  IntColumn get accountClass => integer()();

  /// true pour un compte de regroupement (non mouvementable directement).
  BoolColumn get isHeader => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {code};
}

/// Origine d'une écriture comptable, pour la traçabilité et l'automatisation.
enum EntrySource { manual, sale, purchase, creditPayment, stockAdjustment }

/// Pièce comptable (en-tête d'écriture). Le total des débits de ses lignes
/// doit être égal au total des crédits (partie double).
class JournalEntries extends Table {
  @override
  String get tableName => 'journal_entries';

  TextColumn get id => text()();

  /// Numéro de pièce (ex. EC-2026-000045).
  TextColumn get reference => text()();

  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  TextColumn get description => text()();

  IntColumn get source =>
      intEnum<EntrySource>().withDefault(const Constant(0))();

  /// Identifiant de la pièce d'origine (id de vente, d'achat…), si générée.
  TextColumn get sourceId => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Ligne d'écriture (mouvement sur un compte). Débit XOR crédit renseigné.
class JournalLines extends Table {
  @override
  String get tableName => 'journal_lines';

  TextColumn get id => text()();

  TextColumn get entryId => text().references(JournalEntries, #id)();

  TextColumn get accountCode => text().references(Accounts, #code)();

  TextColumn get label => text()();

  IntColumn get debit => integer().withDefault(const Constant(0))();

  IntColumn get credit => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
