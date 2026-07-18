import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gescompta/core/database/database.dart';
import 'package:gescompta/core/domain/payment_method.dart';
import 'package:gescompta/features/receivables/data/services/drift_repayment_service.dart';
import 'package:gescompta/features/receivables/domain/accounting/syscohada_repayment_posting_policy.dart';
import 'package:gescompta/features/receivables/domain/errors.dart';
import 'package:gescompta/features/receivables/domain/repayment_draft.dart';
import 'package:gescompta/features/receivables/domain/usecases/record_repayment.dart';
import 'package:gescompta/features/sales/data/repositories/drift_accounting_repository.dart';

Future<int> _debit(AppDatabase db, String code) async {
  final lines = await (db.select(db.journalLines)
        ..where((l) => l.accountCode.equals(code)))
      .get();
  return lines.fold<int>(0, (s, l) => s + l.debit);
}

Future<int> _credit(AppDatabase db, String code) async {
  final lines = await (db.select(db.journalLines)
        ..where((l) => l.accountCode.equals(code)))
      .get();
  return lines.fold<int>(0, (s, l) => s + l.credit);
}

void main() {
  late AppDatabase db;
  late RecordRepaymentUseCase useCase;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    var seq = 0;
    final service = DriftRepaymentService(
      db: db,
      accounting: DriftAccountingRepository(db, idGenerator: () => 'a${seq++}'),
      postingPolicy: const SyscohadaRepaymentPostingPolicy(),
      idGenerator: () => 'r${seq++}',
      clock: () => DateTime(2026, 7, 10),
    );
    useCase = RecordRepaymentUseCase(service);

    await db.into(db.customers)
        .insert(CustomersCompanion.insert(id: 'c1', name: 'Diallo'));
    // Deux ventes à crédit non soldées : dette totale 25000.
    await db.into(db.sales).insert(SalesCompanion.insert(
          id: 's1',
          reference: 'V-1',
          customerId: const Value('c1'),
          date: Value(DateTime(2026, 7, 1)),
          totalAmount: const Value(15000),
        ));
    await db.into(db.sales).insert(SalesCompanion.insert(
          id: 's2',
          reference: 'V-2',
          customerId: const Value('c1'),
          date: Value(DateTime(2026, 7, 5)),
          totalAmount: const Value(10000),
        ));
  });

  tearDown(() async => db.close());

  test('remboursement partiel : FIFO, écriture équilibrée, solde diminué',
      () async {
    // 18000 : solde s1 (15000) puis 3000 sur s2.
    final result = await useCase(const RepaymentDraft(
        customerId: 'c1', amount: 18000, method: PaymentMethod.cash));

    expect(result, isA<RecordRepaymentSuccess>());
    final recorded = (result as RecordRepaymentSuccess).repayment;
    expect(recorded.amountApplied, 18000);
    expect(recorded.remainingBalance, 7000); // 25000 - 18000

    // Ventes : s1 soldée, s2 partiellement réglée (paid 3000).
    final s1 = await (db.select(db.sales)..where((s) => s.id.equals('s1')))
        .getSingle();
    final s2 = await (db.select(db.sales)..where((s) => s.id.equals('s2')))
        .getSingle();
    expect(s1.amountPaid, 15000);
    expect(s2.amountPaid, 3000);

    // Deux règlements tracés (un par vente touchée).
    expect(await db.select(db.creditPayments).get(), hasLength(2));

    // Écriture SYSCOHADA équilibrée : débit 571 (caisse) = crédit 411 = 18000.
    expect(await _debit(db, '571'), 18000);
    expect(await _credit(db, '411'), 18000);
    final entries = await db.select(db.journalEntries).get();
    expect(entries, hasLength(1));
  });

  test('remboursement en mobile money : débité au compte 551', () async {
    await useCase(const RepaymentDraft(
        customerId: 'c1', amount: 5000, method: PaymentMethod.mobileMoney));
    expect(await _debit(db, '551'), 5000);
    expect(await _credit(db, '411'), 5000);
  });

  test('montant supérieur à la dette : refus + ROLLBACK complet', () async {
    final result = await useCase(const RepaymentDraft(
        customerId: 'c1', amount: 30000, method: PaymentMethod.cash));

    expect(result, isA<RecordRepaymentFailure>());
    expect((result as RecordRepaymentFailure).error, isA<ExceedsDebtError>());

    // Rien n'a bougé.
    expect(await db.select(db.creditPayments).get(), isEmpty);
    expect(await db.select(db.journalLines).get(), isEmpty);
    final s1 = await (db.select(db.sales)..where((s) => s.id.equals('s1')))
        .getSingle();
    expect(s1.amountPaid, 0);
  });

  test('montant nul : refus (validation)', () async {
    final result = await useCase(
        const RepaymentDraft(customerId: 'c1', amount: 0));
    expect(result, isA<RecordRepaymentFailure>());
    expect((result as RecordRepaymentFailure).error,
        isA<InvalidRepaymentAmountError>());
  });
}
