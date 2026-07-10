import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_metric_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/app_button.dart';
import '../application/dashboard_providers.dart';
import '../domain/entities/dashboard_snapshot.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardDataProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
          child: async.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 120),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Center(child: Text('Erreur : $e')),
            ),
            data: (data) => _DashboardBody(data: data),
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Header(),
        const SizedBox(height: AppSpacing.xl),
        _MetricsGrid(data: data),
        const SizedBox(height: AppSpacing.xl),
        LayoutBuilder(
          builder: (context, c) {
            final side = _Sidebar(data: data);
            final table = _RecentSalesCard(sales: data.recentSales);
            if (c.maxWidth < 1000) {
              return Column(children: [
                table,
                const SizedBox(height: AppSpacing.lg),
                side,
              ]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: table),
                const SizedBox(width: AppSpacing.lg),
                Expanded(flex: 1, child: side),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────── En-tête ───────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tableau de bord',
                  style: AppTypography.displayLg),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Voici comment se porte votre commerce aujourd\'hui, '
                '${formatLongDate(DateTime.now())}.',
                style: AppTypography.bodyLg
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        AppButton(
          onPressed: () => context.go('/vendre'),
          icon: Icons.add_shopping_cart,
          label: 'Nouvelle vente',
        ),
      ],
    );
  }
}

// ─────────────────────────── Grille des indicateurs ───────────────────────────

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.data});

  final DashboardData data;

  String _pct(double? v) => v == null
      ? '—'
      : '${v >= 0 ? '+' : ''}${v.toStringAsFixed(0)} %';

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 180,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
      ),
      children: [
        AppMetricCard(
          title: 'Ventes du jour',
          value: formatGnfCompact(data.todaySales),
          icon: Icons.trending_up,
          variant: AppMetricVariant.primary,
          description: 'vs hier : ${_pct(data.salesGrowth)}',
        ),
        AppMetricCard(
          title: 'Bénéfice du jour',
          value: formatGnfCompact(data.todayProfit),
          icon: Icons.monetization_on,
          variant: AppMetricVariant.standard,
          trendText: _pct(data.profitGrowth),
        ),
        AppMetricCard(
          title: 'On me doit',
          value: formatGnfCompact(data.owed),
          icon: Icons.history,
          variant: AppMetricVariant.error,
          trendText: '${data.owedCount} en attente',
        ),
        AppMetricCard(
          title: 'Argent disponible',
          value: formatGnfCompact(data.cashAvailable),
          icon: Icons.account_balance_wallet,
          variant: AppMetricVariant.standard,
          trendText: data.cashAvailable >= 0 ? 'Sain' : 'Négatif',
        ),
        AppMetricCard(
          title: 'Stock faible',
          value: '${data.lowStock.length}',
          suffix: 'articles',
          icon: Icons.inventory,
          variant: data.lowStock.isEmpty ? AppMetricVariant.standard : AppMetricVariant.error,
          trendText: data.lowStock.isEmpty ? 'Tout va bien' : 'Action requise',
        ),
      ],
    );
  }
}

// ─────────────────────────── Ventes récentes ───────────────────────────

class _RecentSalesCard extends StatelessWidget {
  const _RecentSalesCard({required this.sales});

  final List<RecentSaleView> sales;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ventes récentes', style: theme.textTheme.titleMedium),
                AppButton.secondary(
                  onPressed: () => context.go('/mon-commerce'),
                  label: 'Voir tout',
                ),
              ],
            ),
          ),
          if (sales.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text('Aucune vente pour le moment.',
                    style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            )
          else
            AppTable(
              columns: const [
                DataColumn(label: Text('CLIENT / ARTICLE')),
                DataColumn(label: Text('HEURE')),
                DataColumn(label: Text('MONTANT')),
                DataColumn(label: Text('STATUT')),
              ],
              rows: sales.map((sale) => DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Icon(sale.icon, color: theme.colorScheme.primary, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(sale.title,
                                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                            Text(sale.subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(formatRelativeDay(sale.date),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ),
                  DataCell(
                    Text(formatGnf(sale.amount),
                        style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                  ),
                  DataCell(
                    sale.paid
                        ? const AppChip(label: 'Payé', status: AppChipStatus.success)
                        : const AppChip(label: 'Crédit', status: AppChipStatus.error),
                  ),
                ],
              )).toList(),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Colonne latérale ───────────────────────────

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WeeklyGrowthCard(growth: data.weeklyGrowth),
        const SizedBox(height: AppSpacing.lg),
        _RestockCard(products: data.lowStock),
      ],
    );
  }
}

class _WeeklyGrowthCard extends StatelessWidget {
  const _WeeklyGrowthCard({required this.growth});

  final double? growth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = growth == null
        ? '—'
        : '${growth! >= 0 ? '+' : ''}${growth!.toStringAsFixed(1)} %';
    return Container(
      height: 192,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
              color: Color(0x20000000), offset: Offset(0, 4), blurRadius: 12),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -20,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: .2,
              child: CustomPaint(
                size: const Size(double.infinity, 80),
                painter: _WavePainter(),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Croissance de la semaine',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(alpha: 0.8))),
                  const SizedBox(height: AppSpacing.xs),
                  Text(label,
                      style: theme.textTheme.displayMedium
                          ?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Pouls du commerce en temps réel',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, h * 0.7)
      ..cubicTo(w * .3, h * .2, w * .7, h * 1.2, w, h * .4)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RestockCard extends StatelessWidget {
  const _RestockCard({required this.products});

  final List<LowStockItem> products;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('À réapprovisionner', style: theme.textTheme.titleSmall),
              if (products.isNotEmpty)
                const AppChip(label: 'CRITIQUE', status: AppChipStatus.error),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (products.isEmpty)
            Text('Aucun produit à réapprovisionner 👍',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
          else ...[
            for (final p in products.take(3)) _RestockRow(product: p),
            const SizedBox(height: AppSpacing.lg),
            AppButton.secondary(
              onPressed: () => context.go('/fournisseurs'),
              label: 'Commander',
            ),
          ],
        ],
      ),
    );
  }
}

class _RestockRow extends StatelessWidget {
  const _RestockRow({required this.product});

  final LowStockItem product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final critical = product.stockQuantity <= 2;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(Icons.inventory_2_outlined,
                size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium),
          ),
          Text(
            'reste ${formatQuantity(product.stockQuantity)}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: critical
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
