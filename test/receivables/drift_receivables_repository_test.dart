import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gescompta/core/database/database.dart';
import 'package:gescompta/features/receivables/data/repositories/drift_receivables_repository.dart';

/// Vérifie le cahier de crédit : solde par client agrégé en SQL, ventes soldées
/// et ventes comptoir exclues, tri par solde décroissant.
void main() {
  late AppDatabase db;
  late DriftReceivablesRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftReceivablesRepository(db);

    await db.into(db.customers).insert(
        CustomersCompanion.insert(id: 'c1', name: 'Diallo', phone: const Value('620')));
    await db.into(db.customers)
        .insert(CustomersCompanion.insert(id: 'c2', name: 'Barry'));

    Future<void> sale(String id, String? customer, DateTime date, int total,
        int paid) async {
      await db.into(db.sales).insert(SalesCompanion.insert(
            id: id,
            reference: 'V-$id',
            customerId: Value(customer),
            date: Value(date),
            totalAmount: Value(total),
            amountPaid: Value(paid),
          ));
    }

    // Diallo : deux ventes dues (15000 + 5000 = 20000).
    await sale('s1', 'c1', DateTime(2026, 7, 1), 20000, 5000);
    await sale('s2', 'c1', DateTime(2026, 7, 5), 5000, 0);
    // Diallo : une vente soldée (exclue).
    await sale('s3', 'c1', DateTime(2026, 7, 6), 8000, 8000);
    // Barry : une vente due (7000).
    await sale('s4', 'c2', DateTime(2026, 7, 4), 7000, 0);
    // Vente comptoir (sans client) due : exclue faute de client.
    await sale('s5', null, DateTime(2026, 7, 7), 3000, 0);
  });

  tearDown(() async => db.close());

  test('soldes par client, triés du plus gros débiteur au plus petit',
      () async {
    final summaries = await repo.watchCreditSummaries().first;

    expect(summaries, hasLength(2));
    // Diallo (20000) avant Barry (7000).
    expect(summaries[0].customerName, 'Diallo');
    expect(summaries[0].balance, 20000);
    expect(summaries[0].salesCount, 2); // s1 + s2 (s3 soldée exclue)
    expect(summaries[0].customerPhone, '620');
    expect(summaries[0].lastSaleDate, DateTime(2026, 7, 5));

    expect(summaries[1].customerName, 'Barry');
    expect(summaries[1].balance, 7000);
    expect(summaries[1].salesCount, 1);
  });

  test('aucun débiteur → liste vide', () async {
    await (db.update(db.sales)).write(
        const SalesCompanion(amountPaid: Value(999999)));
    final summaries = await repo.watchCreditSummaries().first;
    expect(summaries, isEmpty);
  });
}
