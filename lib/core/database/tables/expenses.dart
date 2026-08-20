import 'package:drift/drift.dart';

import '../../domain/payment_method.dart';

export '../../domain/payment_method.dart' show PaymentMethod;

/// Catégories de dépenses courantes pour une boutique / entreprise.
enum ExpenseCategory {
  rent,           // Loyer
  salary,         // Salaire
  utilities,      // Électricité & Eau
  transport,      // Transport / Logistique
  maintenance,    // Maintenance & Réparation
  marketing,      // Marketing & Publicité
  supplies,       // Fournitures de bureau / boutique
  taxes,          // Taxes & Impôts
  other,          // Divers
}

/// Extensions pour faciliter l'affichage des catégories.
extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.rent:
        return 'Loyer';
      case ExpenseCategory.salary:
        return 'Salaires';
      case ExpenseCategory.utilities:
        return 'Électricité & Eau';
      case ExpenseCategory.transport:
        return 'Transport & Logistique';
      case ExpenseCategory.maintenance:
        return 'Maintenance & Réparation';
      case ExpenseCategory.marketing:
        return 'Marketing & Publicité';
      case ExpenseCategory.supplies:
        return 'Fournitures';
      case ExpenseCategory.taxes:
        return 'Taxes & Impôts';
      case ExpenseCategory.other:
        return 'Divers';
    }
  }
}

/// Dépenses opérationnelles de l'entreprise.
class Expenses extends Table {
  @override
  String get tableName => 'expenses';

  TextColumn get id => text()();

  /// Numéro de référence, ex: DEP-0001
  TextColumn get reference => text()();

  /// Catégorie de la dépense
  IntColumn get category => intEnum<ExpenseCategory>()();

  /// Montant de la dépense (en GNF)
  IntColumn get amount => integer()();

  /// Date de la dépense
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  /// Motif ou description libre
  TextColumn get description => text()();

  /// Mode de paiement (espèces, mobile money, virement, etc.)
  IntColumn get paymentMethod => intEnum<PaymentMethod>().withDefault(const Constant(0))();

  /// Optionnel: URL ou chemin d'accès vers un justificatif (reçu, facture)
  TextColumn get receiptUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
