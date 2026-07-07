import 'package:drift/drift.dart';

/// Client — utilisé principalement pour le suivi des créances (« cahier de crédit »).
class Customers extends Table {
  @override
  String get tableName => 'customers';

  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 200)();

  TextColumn get phone => text().nullable()();

  TextColumn get address => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
