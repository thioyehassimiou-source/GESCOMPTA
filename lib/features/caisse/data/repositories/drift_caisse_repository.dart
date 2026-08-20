import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/domain/cash_movement_type.dart';
import '../../../../core/domain/payment_method.dart';
import '../../../../core/providers/database_provider.dart';

final caisseRepositoryProvider = Provider<DriftCaisseRepository>((ref) {
  return DriftCaisseRepository(ref.watch(databaseProvider));
});

class DriftCaisseRepository {
  DriftCaisseRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  /// Enregistre un mouvement manuel de caisse (Entrée ou Sortie).
  Future<void> insertMovement({
    required CashMovementType type,
    required String description,
    required int amount,
    required PaymentMethod paymentMethod,
  }) async {
    final id = _uuid.v4();
    final isOutflow = type == CashMovementType.outflow;
    final prefix = isOutflow ? 'DEC' : 'ENC';
    final ref = '$prefix-${id.substring(0, 6).toUpperCase()}';

    await _db.into(_db.cashMovements).insert(
      CashMovementsCompanion.insert(
        id: id,
        reference: ref,
        description: description,
        amount: amount,
        type: type,
        date: Value(DateTime.now()),
        paymentMethod: Value(paymentMethod),
      ),
    );
  }
}
