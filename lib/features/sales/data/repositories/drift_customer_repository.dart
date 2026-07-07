import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../domain/repositories/customer_repository.dart';

/// Implémentation Drift de [CustomerRepository].
class DriftCustomerRepository implements CustomerRepository {
  DriftCustomerRepository(this._db, {String Function()? idGenerator})
      : _newId = idGenerator ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final String Function() _newId;

  @override
  Future<String> create(String name) async {
    final id = _newId();
    await _db.into(_db.customers).insert(
          CustomersCompanion.insert(id: id, name: name),
        );
    return id;
  }
}
