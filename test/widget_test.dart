import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmashop/core/database/database.dart';

void main() {
  test('La base de données se crée et se ferme sans erreur', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    // Force l'ouverture (déclenche onCreate).
    final products = await db.select(db.products).get();
    expect(products, isEmpty);
    await db.close();
  });
}
