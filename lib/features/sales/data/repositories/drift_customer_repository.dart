import 'package:drift/drift.dart';
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
  Future<String> getOrCreate(String name, {String? phone}) async {
    final cleanName = name.trim();
    // Rechercher un client existant (insensible à la casse)
    final existing = await (_db.select(_db.customers)
          ..where((c) => c.name.lower().equals(cleanName.toLowerCase()))
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) {
      // Met à jour le téléphone si fourni et absent ou différent
      if (phone != null && phone.trim().isNotEmpty && existing.phone != phone.trim()) {
        await (_db.update(_db.customers)
              ..where((c) => c.id.equals(existing.id)))
            .write(CustomersCompanion(phone: Value(phone.trim())));
      }
      return existing.id;
    }

    final id = _newId();
    await _db.into(_db.customers).insert(
          CustomersCompanion.insert(
            id: id,
            name: cleanName,
            phone: Value(phone?.trim()),
          ),
        );
    return id;
  }
}
