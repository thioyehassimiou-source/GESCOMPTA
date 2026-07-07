/// Origine métier d'une écriture, indépendante de la couche data.
/// La couche data la mappe vers l'enum persistant `EntrySource`.
enum AccountingSource { manual, sale, purchase, creditPayment, stockAdjustment }

/// Une ligne d'écriture en brouillon (un mouvement sur un compte).
/// Débit XOR crédit renseigné (l'autre vaut 0).
class JournalLineDraft {
  const JournalLineDraft({
    required this.accountCode,
    required this.label,
    this.debit = 0,
    this.credit = 0,
  });

  JournalLineDraft.debit(this.accountCode, this.label, int amount)
      : debit = amount,
        credit = 0;

  JournalLineDraft.credit(this.accountCode, this.label, int amount)
      : debit = 0,
        credit = amount;

  final String accountCode;
  final String label;
  final int debit;
  final int credit;
}

/// Une pièce comptable en brouillon. La [reference] est attribuée par le
/// repository au moment de l'insertion (numérotation continue).
class JournalEntryDraft {
  const JournalEntryDraft({
    required this.date,
    required this.description,
    required this.source,
    required this.sourceId,
    required this.lines,
  });

  final DateTime date;
  final String description;
  final AccountingSource source;
  final String? sourceId;
  final List<JournalLineDraft> lines;

  int get totalDebit => lines.fold(0, (s, l) => s + l.debit);
  int get totalCredit => lines.fold(0, (s, l) => s + l.credit);

  /// Une écriture SYSCOHADA doit être équilibrée (partie double).
  bool get isBalanced => totalDebit == totalCredit;
}
