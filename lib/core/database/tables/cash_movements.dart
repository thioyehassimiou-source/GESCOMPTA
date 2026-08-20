import 'package:drift/drift.dart';

import '../../domain/cash_movement_type.dart';
import '../../domain/payment_method.dart';

export '../../domain/cash_movement_type.dart' show CashMovementType;
export '../../domain/payment_method.dart' show PaymentMethod;

/// Opérations manuelles de caisse (entrées ou sorties).
class CashMovements extends Table {
  @override
  String get tableName => 'cash_movements';

  TextColumn get id => text()();

  /// Numéro de référence, ex: CAISSE-IN-0001
  TextColumn get reference => text()();

  /// Description / Motif du mouvement
  TextColumn get description => text()();

  /// Montant du mouvement (en GNF)
  IntColumn get amount => integer()();

  /// Type de mouvement (entrée ou sortie)
  IntColumn get type => intEnum<CashMovementType>()();

  /// Date et heure du mouvement
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  /// Mode de paiement (espèces, mobile money, etc.)
  IntColumn get paymentMethod => intEnum<PaymentMethod>().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
