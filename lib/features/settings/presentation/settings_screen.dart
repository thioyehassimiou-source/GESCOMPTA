import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Réglages', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Configuration de votre boutique et sauvegarde.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _tile(
                  context,
                  icon: Icons.storefront,
                  title: 'Ma boutique',
                  subtitle: 'Nom, adresse, contact (affichés sur les reçus)',
                ),
                _tile(
                  context,
                  icon: Icons.category_outlined,
                  title: 'Secteur d\'activité',
                  subtitle:
                      'Épicerie, pièces détachées, pharmacie, textile…',
                ),
                _tile(
                  context,
                  icon: Icons.backup_outlined,
                  title: 'Sauvegarde',
                  subtitle: 'Sauvegarde locale automatique et export des données',
                ),
                _tile(
                  context,
                  icon: Icons.smart_toy_outlined,
                  title: 'Assistant intelligent',
                  subtitle: 'Activer l\'assistant (connexion internet requise)',
                ),
                const Divider(height: 32),
                // Accès discret réservé au comptable — hors du menu principal.
                Card(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.calculate_outlined),
                    title: const Text('Espace comptable'),
                    subtitle: const Text(
                      'Pour votre comptable : documents officiels générés automatiquement',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/reglages/espace-comptable'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('« $title » — à implémenter (V1).')),
      ),
    );
  }
}
