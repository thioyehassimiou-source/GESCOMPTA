import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../../../core/database/database.dart';
import '../data/services/drift_audit_log_service.dart';
import '../domain/services/audit_log_service.dart';

final auditLogServiceProvider = Provider<AuditLogService>(
  (ref) => DriftAuditLogService(ref.watch(databaseProvider)),
);

final auditLogsProvider = FutureProvider<List<AuditLog>>((ref) async {
  return ref.watch(auditLogServiceProvider).getLogs();
});
