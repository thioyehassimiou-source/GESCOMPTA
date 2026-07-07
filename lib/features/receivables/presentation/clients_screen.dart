import 'package:flutter/material.dart';

import '../../common/module_placeholder.dart';

/// « Clients & crédits » — le cahier de crédit numérique.
/// Répond à la question du commerçant : « Qui me doit de l'argent ? »
class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Clients & crédits',
      icon: Icons.people,
      description:
          'Votre cahier de crédit, en plus clair. Vous voyez d\'un coup d\'œil '
          'qui vous doit de l\'argent et combien il reste à payer.',
      bullets: [
        'Vendre à crédit à un client connu',
        'Enregistrer un remboursement (même partiel)',
        'Voir le solde restant de chaque client',
        'Être prévenu des dettes anciennes à réclamer',
      ],
    );
  }
}
