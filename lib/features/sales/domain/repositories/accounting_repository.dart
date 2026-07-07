import '../accounting/journal_draft.dart';

/// Persistance des écritures comptables (générées en arrière-plan).
abstract interface class AccountingRepository {
  /// Enregistre une pièce comptable équilibrée et ses lignes.
  ///
  /// Attribue la référence continue (ex. EC-2026-000045) et **rejette** toute
  /// pièce déséquilibrée (garde-fou de la partie double).
  Future<void> postEntry(JournalEntryDraft entry);
}
