import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gescompta/core/database/database.dart';
import 'package:gescompta/core/database/seed/syscohada_accounts.dart';

void main() {
  test('Le plan comptable SYSCOHADA est semé à la création de la base',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    // Force l'ouverture (déclenche onCreate + seed).
    final accounts = await db.select(db.accounts).get();
    expect(accounts.length, kSyscohadaSeedAccounts.length);
    expect(accounts.any((a) => a.code == '701'), isTrue);
    await db.close();
  });
}
