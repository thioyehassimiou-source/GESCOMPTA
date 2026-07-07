import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/database/database.dart';
import 'core/providers/database_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise les données de localisation FR (formats de dates/nombres).
  await initializeDateFormatting('fr', null);

  // Ouvre la base locale une seule fois et l'injecte dans l'arbre Riverpod.
  final database = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const GescomptaApp(),
    ),
  );
}
