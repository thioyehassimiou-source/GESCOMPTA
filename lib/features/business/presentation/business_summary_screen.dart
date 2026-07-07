import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/providers/database_provider.dart';

/// Résumé du commerce en langage simple. Aucune notion comptable :
/// pas de balance, pas de comptes, pas de débit/crédit.
class BusinessSummary {
  const BusinessSummary({
    required this.monthSales,
    required this.monthProfit,
    required this.owedToMe,
    required this.cashCollectedThisMonth,
  });

  final int monthSales; // ventes du mois (GNF)
  final int monthProfit; // bénéfice estimé du mois (GNF)
  final int owedToMe; // ce que les clients me doivent (GNF)
  final int cashCollectedThisMonth; // argent réellement encaissé ce mois (GNF)
}

final businessSummaryProvider = FutureProvider<BusinessSummary>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month);

  final sales = await db.select(db.sales).get();
  final items = await db.select(db.saleItems).get();

  final monthSaleIds = sales
      .where((s) => !s.date.isBefore(startOfMonth))
      .map((s) => s.id)
      .toSet();

  var monthSales = 0;
  var cashCollected = 0;
  for (final s in sales) {
    if (monthSaleIds.contains(s.id)) {
      monthSales += s.totalAmount;
      cashCollected += s.amountPaid;
    }
  }

  var monthProfit = 0;
  for (final it in items) {
    if (monthSaleIds.contains(it.saleId)) {
      monthProfit += it.lineTotal - (it.unitCost * it.quantity).round();
    }
  }

  final owedToMe =
      sales.fold<int>(0, (sum, s) => sum + (s.totalAmount - s.amountPaid));

  return BusinessSummary(
    monthSales: monthSales,
    monthProfit: monthProfit,
    owedToMe: owedToMe,
    cashCollectedThisMonth: cashCollected,
  );
});

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
