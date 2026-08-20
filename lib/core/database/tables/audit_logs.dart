import 'package:drift/drift.dart';

/// Types d'actions journalisées pour des raisons de sécurité.
enum AuditActionType {
  saleCancelled,
  productPriceChanged,
  productDeleted,
  expenseDeleted,
  purchaseDeleted,
  cashClosed,
  userManaged,
  settingsChanged,
}

/// Table contenant le journal d'activité (Audit Logs).
@DataClassName('AuditLog')
class AuditLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  
  /// Identifiant de l'utilisateur ayant effectué l'action.
  TextColumn get userId => text()();
  
  /// Nom de l'utilisateur au moment de l'action.
  TextColumn get userName => text()();
  
  /// Type d'action.
  TextColumn get actionType => textEnum<AuditActionType>()();
  
  /// Détails techniques ou fonctionnels de l'action (en format texte ou JSON).
  TextColumn get details => text()();

  @override
  Set<Column> get primaryKey => {id};
}
