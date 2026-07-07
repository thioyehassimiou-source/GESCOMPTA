import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'seed/syscohada_accounts.dart';
import 'tables/accounting.dart';
import 'tables/customers.dart';
import 'tables/products.dart';
import 'tables/sales.dart';
import 'tables/stock.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    Customers,
    Sales,
    SaleItems,
    CreditPayments,
    StockMovements,
    Accounts,
    JournalEntries,
    JournalLines,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructeur de test : base en mémoire, sans fichier ni path_provider.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedAccounts();
        },
        beforeOpen: (details) async {
          // Intégrité référentielle : indispensable pour garantir qu'aucune
          // écriture ne pointe vers un compte/produit inexistant, et que le
          // rollback du moteur de vente laisse une base cohérente.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Insère le plan comptable SYSCOHADA au premier lancement.
  Future<void> _seedAccounts() async {
    await batch((b) {
      b.insertAll(
        accounts,
        kSyscohadaSeedAccounts.map(
          (a) => AccountsCompanion.insert(
            code: a.code,
            label: a.label,
            accountClass: a.accountClass,
            isHeader: Value(a.isHeader),
          ),
        ),
      );
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'gescompta.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
