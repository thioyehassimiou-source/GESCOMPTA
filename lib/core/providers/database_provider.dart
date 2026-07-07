import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';

/// Instance unique de la base de données pour toute l'application.
///
/// Surchargée dans `main()` avec l'instance réellement ouverte, afin de
/// centraliser le cycle de vie (ouverture/fermeture) au démarrage.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'databaseProvider doit être surchargé dans ProviderScope au démarrage.',
  );
});
