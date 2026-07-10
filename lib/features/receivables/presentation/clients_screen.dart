import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../application/receivables_providers.dart';
import '../domain/credit_summary.dart';

/// « Clients & crédits » — le cahier de crédit numérique.
/// Répond à la question du commerçant : « Qui me doit de l'argent ? »
class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(creditSummariesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clients & crédits', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Votre cahier de crédit : qui vous doit de l\'argent, et combien il '
            'reste à payer. Mise à jour automatique à chaque vente.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
              data: (summaries) {
                if (summaries.isEmpty) return const _EmptyState();
                final totalOwed =
                    summaries.fold<int>(0, (s, c) => s + c.balance);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TotalCard(total: totalOwed, clients: summaries.length),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: summaries.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) =>
                            _CreditTile(summary: summaries[i]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline,
              size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text('Personne ne vous doit d\'argent.',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Toutes vos ventes sont réglées.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total, required this.clients});

  final int total;
  final int clients;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            const Text('👥', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Total dû par $clients ${clients > 1 ? 'clients' : 'client'}',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text(
              formatGnf(total),
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditTile extends StatelessWidget {
  const _CreditTile({required this.summary});

  final CreditSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      if (summary.customerPhone != null && summary.customerPhone!.isNotEmpty)
        summary.customerPhone!,
      '${summary.salesCount} '
          '${summary.salesCount > 1 ? 'ventes' : 'vente'} à crédit',
      'depuis ${formatRelativeDay(summary.lastSaleDate)}',
    ].join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Text(
            summary.customerName.characters.first.toUpperCase(),
            style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
          ),
        ),
        title: Text(summary.customerName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Text(
          formatGnf(summary.balance),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}
