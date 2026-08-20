import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmashop/core/database/database.dart';
import 'package:nmashop/core/domain/payment_method.dart';
import 'package:nmashop/features/receivables/data/services/drift_repayment_service.dart';
import 'package:nmashop/features/receivables/domain/errors.dart';
import 'package:nmashop/features/receivables/domain/repayment_draft.dart';
import 'package:nmashop/features/receivables/domain/usecases/record_repayment.dart';

void main() {
  late AppDatabase db;
  late RecordRepaymentUseCase useCase;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    var seq = 0;
    final service = DriftRepaymentService(
      db: db,
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

  test('remboursement partiel : FIFO, solde diminué, règlements tracés',
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
  });

  test('montant supérieur à la dette : refus + ROLLBACK complet', () async {
    final result = await useCase(const RepaymentDraft(
        customerId: 'c1', amount: 30000, method: PaymentMethod.cash));

    expect(result, isA<RecordRepaymentFailure>());
    expect((result as RecordRepaymentFailure).error, isA<ExceedsDebtError>());

    // Rien n'a bougé.
    expect(await db.select(db.creditPayments).get(), isEmpty);
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

  test('remboursement total : solde à zéro', () async {
    final result = await useCase(const RepaymentDraft(
        customerId: 'c1', amount: 25000, method: PaymentMethod.cash));

    expect(result, isA<RecordRepaymentSuccess>());
    final recorded = (result as RecordRepaymentSuccess).repayment;
    expect(recorded.remainingBalance, 0);

    final payments = await db.select(db.creditPayments).get();
    expect(payments, hasLength(2)); // un par vente
  });
}
