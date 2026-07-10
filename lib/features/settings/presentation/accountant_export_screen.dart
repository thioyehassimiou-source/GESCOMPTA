import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../accounting/application/accounting_providers.dart';

/// Espace réservé au comptable. C'est le SEUL écran où apparaît le vocabulaire
/// SYSCOHADA (plan comptable, journal, balance). Le commerçant n'y vient pas :
/// on y accède uniquement depuis Réglages, avec un avertissement explicite.
class AccountantExportScreen extends ConsumerWidget {
  const AccountantExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(chartOfAccountsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace comptable'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/reglages'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cette section est destinée à votre comptable. '
                      'Vous n\'avez pas besoin d\'y toucher : GESCOMPTA génère '
                      'ces documents automatiquement à partir de vos ventes et achats.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Documents SYSCOHADA', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ExportButton(
                    icon: Icons.menu_book, label: 'Journal (PDF)'),
                _ExportButton(
                    icon: Icons.list_alt, label: 'Grand livre (PDF)'),
                _ExportButton(icon: Icons.balance, label: 'Balance (PDF)'),
              ],
            ),
            const SizedBox(height: 24),
            Text('Plan comptable', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: accountsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur : $e')),
                data: (accounts) => Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                  child: ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (_, i) {
                      final a = accounts[i];
                      return ListTile(
                        dense: true,
                        leading: SizedBox(
                          width: 56,
                          child: Text(a.code,
                              style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: a.isHeader
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                        title: Text(a.label),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('« $label » — export à implémenter (V1).')),
        );
      },
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
