import '../entities/account.dart';

/// Accès en lecture au plan comptable SYSCOHADA.
abstract interface class AccountRepository {
  /// Flux réactif du plan comptable, trié par code.
  Stream<List<Account>> watchChartOfAccounts();
}
