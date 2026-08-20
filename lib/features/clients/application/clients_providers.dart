import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import 'package:drift/drift.dart';

final clientsStreamProvider = StreamProvider<List<Customer>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.customers)
        ..orderBy([
          (c) => OrderingTerm(expression: c.name, mode: OrderingMode.asc)
        ]))
      .watch();
});
