import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/tables/accounting.dart';
import '../../domain/accounting/journal_draft.dart';
import '../../domain/repositories/accounting_repository.dart';

/// Implémentation Drift de [AccountingRepository].
///
/// Garantit la partie double : une pièce déséquilibrée est rejetée avant toute
/// insertion (l'exception fait remonter le rollback de la transaction du moteur).
class DriftAccountingRepository implements AccountingRepository {
  DriftAccountingRepository(this._db, {String Function()? idGenerator})
      : _newId = idGenerator ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final String Function() _newId;

  @override
  Future<void> postEntry(JournalEntryDraft entry) async {
    if (!entry.isBalanced) {
      throw StateError(
        'Écriture déséquilibrée (débit=${entry.totalDebit}, '
        'crédit=${entry.totalCredit}) : ${entry.description}',
      );
    }

    final reference = await _nextReference(entry.date);
    final entryId = _newId();

    await _db.into(_db.journalEntries).insert(
          JournalEntriesCompanion.insert(
            id: entryId,
            reference: reference,
            date: Value(entry.date),
            description: entry.description,
            source: Value(_mapSource(entry.source)),
            sourceId: Value(entry.sourceId),
          ),
        );

    await _db.batch((b) {
      b.insertAll(_db.journalLines, [
        for (final l in entry.lines)
          JournalLinesCompanion.insert(
            id: _newId(),
            entryId: entryId,
            accountCode: l.accountCode,
            label: l.label,
            debit: Value(l.debit),
            credit: Value(l.credit),
          ),
      ]);
    });
  }

  Future<String> _nextReference(DateTime date) async {
    final year = date.year;
    final count = _db.journalEntries.id.count(
      filter: _db.journalEntries.date.isBiggerOrEqualValue(DateTime(year)) &
          _db.journalEntries.date.isSmallerThanValue(DateTime(year + 1)),
    );
    final query = _db.selectOnly(_db.journalEntries)..addColumns([count]);
    final n = await query.map((row) => row.read(count) ?? 0).getSingle();
    return 'EC-$year-${(n + 1).toString().padLeft(6, '0')}';
  }

  EntrySource _mapSource(AccountingSource source) => switch (source) {
        AccountingSource.manual => EntrySource.manual,
        AccountingSource.sale => EntrySource.sale,
        AccountingSource.purchase => EntrySource.purchase,
        AccountingSource.creditPayment => EntrySource.creditPayment,
        AccountingSource.stockAdjustment => EntrySource.stockAdjustment,
      };
}
