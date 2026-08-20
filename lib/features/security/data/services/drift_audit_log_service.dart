import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/tables/audit_logs.dart';
import '../../domain/services/audit_log_service.dart';

class DriftAuditLogService implements AuditLogService {
  DriftAuditLogService(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<void> logAction({
    required String userId,
    required String userName,
    required AuditActionType actionType,
    required String details,
  }) async {
    await _db.into(_db.auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        date: DateTime.now(),
        userId: userId,
        userName: userName,
        actionType: actionType,
        details: details,
      ),
    );
  }

  @override
  Future<List<AuditLog>> getLogs() async {
    return (_db.select(_db.auditLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }
}
