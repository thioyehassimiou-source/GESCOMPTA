import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../data/repositories/drift_account_repository.dart';
import '../domain/entities/account.dart';
import '../domain/repositories/account_repository.dart';

/// Câblage Riverpod du plan comptable.

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => DriftAccountRepository(ref.watch(databaseProvider)),
);

/// Flux réactif du plan comptable SYSCOHADA, exposé à la présentation.
final chartOfAccountsProvider = StreamProvider<List<Account>>(
  (ref) => ref.watch(accountRepositoryProvider).watchChartOfAccounts(),
);
