import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gescompta/core/database/database.dart';
import 'package:gescompta/features/accounting/data/repositories/drift_account_repository.dart';

/// Le plan comptable SYSCOHADA est semé au premier lancement ; le repository
/// doit l'exposer trié par code, en entités de domaine.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  test('watchChartOfAccounts renvoie les comptes semés, triés par code',
      () async {
    final repo = DriftAccountRepository(db);
    final accounts = await repo.watchChartOfAccounts().first;

    expect(accounts, isNotEmpty);
    // Le compte client 411 (classe 4) fait partie du plan SYSCOHADA de base.
    expect(accounts.any((a) => a.code == '411'), isTrue);
    // Tri strictement croissant par code.
    final codes = accounts.map((a) => a.code).toList();
    final sorted = [...codes]..sort();
    expect(codes, sorted);
  });
}
