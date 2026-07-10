import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../application/business_providers.dart';

class BusinessSummaryScreen extends ConsumerWidget {
  const BusinessSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(businessSummaryProvider);
    final theme = Theme.of(context);
    final monthName = _monthLabel(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mon commerce', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Comment va votre boutique, en clair. Mise à jour automatique à '
            'chaque vente.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
              data: (s) => ListView(
                children: [
                  _SummaryLine(
                    emoji: '💰',
                    title: 'Ventes de $monthName',
                    value: formatGnf(s.monthSales),
                  ),
                  _SummaryLine(
                    emoji: '📈',
                    title: 'Bénéfice estimé de $monthName',
                    value: formatGnf(s.monthProfit),
                    highlight: true,
                  ),
                  _SummaryLine(
                    emoji: '💵',
                    title: 'Argent encaissé ce mois',
                    value: formatGnf(s.cashCollectedThisMonth),
                  ),
                  _SummaryLine(
                    emoji: '👥',
                    title: 'Ce que les clients me doivent',
                    value: formatGnf(s.owedToMe),
                  ),
                  const SizedBox(height: 24),
                  _AccountantCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime d) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet',
      'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return months[d.month - 1];
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.emoji,
    required this.title,
    required this.value,
    this.highlight = false,
  });

  final String emoji;
  final String title;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: highlight
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renvoie discrètement vers l'espace comptable, sans jargon dans le corps.
class _AccountantCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: const Text('Vous avez un comptable ?'),
        subtitle: const Text(
          'GESCOMPTA prépare tout seul les documents officiels dont il a besoin.',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/reglages/espace-comptable'),
      ),
    );
  }
}
