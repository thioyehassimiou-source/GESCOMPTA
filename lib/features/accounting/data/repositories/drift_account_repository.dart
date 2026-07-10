import 'package:drift/drift.dart';

// La classe Drift générée `Account` est masquée : la couche data expose
// exclusivement l'entité de domaine du même nom.
import '../../../../core/database/database.dart' hide Account;
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

/// Implémentation Drift de [AccountRepository].
class DriftAccountRepository implements AccountRepository {
  DriftAccountRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Account>> watchChartOfAccounts() {
    return (_db.select(_db.accounts)
          ..orderBy([(t) => OrderingTerm(expression: t.code)]))
        .watch()
        .map((rows) => rows
            .map((r) => Account(
                  code: r.code,
                  label: r.label,
                  accountClass: r.accountClass,
                  isHeader: r.isHeader,
                ))
            .toList(growable: false));
  }
}
