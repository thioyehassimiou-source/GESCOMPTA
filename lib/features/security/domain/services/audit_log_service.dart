import '../../../../core/database/database.dart';
import '../../../../core/database/tables/audit_logs.dart';

abstract interface class AuditLogService {
  /// Enregistre une action sensible dans le journal d'audit.
  Future<void> logAction({
    required String userId,
    required String userName,
    required AuditActionType actionType,
    required String details,
  });

  /// Récupère l'historique complet des actions, des plus récentes aux plus anciennes.
  Future<List<AuditLog>> getLogs();
}
