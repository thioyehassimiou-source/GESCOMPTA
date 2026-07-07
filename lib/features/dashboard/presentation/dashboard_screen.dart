import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database.dart';
import '../../../core/format/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/status_pill.dart';
import '../application/dashboard_providers.dart';

/// Écran Accueil — fidèle à la maquette (« Today's Business Story »), en
/// français et branché aux vraies données. Zéro jargon comptable.
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
              Text('Votre activité aujourd\'hui',
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
        FilledButton.icon(
          onPressed: () => context.go('/vendre'),
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Nouvelle vente'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
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
        mainAxisExtent: 138,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
      ),
      children: [
        MetricCard(
          label: 'Ventes du jour',
          value: formatGnfCompact(data.todaySales),
          icon: Icons.trending_up,
          valueColor: AppColors.primary,
          trendText: _pct(data.salesGrowth),
          trendColor: (data.salesGrowth ?? 0) >= 0
              ? AppColors.primary
              : AppColors.error,
          trendHint: 'vs hier',
        ),
        MetricCard(
          label: 'Bénéfice du jour',
          value: formatGnfCompact(data.todayProfit),
          icon: Icons.monetization_on,
          valueColor: AppColors.primary,
          trendText: _pct(data.profitGrowth),
          trendColor: (data.profitGrowth ?? 0) >= 0
              ? AppColors.primary
              : AppColors.error,
          trendHint: 'marge',
        ),
        MetricCard(
          label: 'On me doit',
          value: formatGnfCompact(data.owed),
          icon: Icons.history,
          iconColor: AppColors.error,
          iconBackground: AppColors.errorContainer,
          trendText: '${data.owedCount} en attente',
          trendColor: AppColors.error,
          trendHint: 'à recouvrer',
        ),
        MetricCard(
          label: 'Argent disponible',
          value: formatGnfCompact(data.cashAvailable),
          icon: Icons.account_balance_wallet,
          iconColor: AppColors.secondary,
          iconBackground: AppColors.secondaryContainer,
          trendText: data.cashAvailable >= 0 ? 'Sain' : 'Négatif',
          trendColor: data.cashAvailable >= 0
              ? AppColors.primary
              : AppColors.error,
          trendHint: 'trésorerie',
        ),
        MetricCard(
          label: 'Stock faible',
          value: '${data.lowStock.length} article(s)',
          icon: Icons.inventory,
          iconColor: AppColors.onTertiaryFixedVariant,
          iconBackground: AppColors.tertiaryFixed,
          trendText: data.lowStock.isEmpty ? 'Tout va bien' : 'Action requise',
          trendColor: AppColors.onTertiaryFixedVariant,
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
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ventes récentes', style: AppTypography.headlineMd),
                InkWell(
                  onTap: () => context.go('/mon-commerce'),
                  child: Text('Voir tout',
                      style: AppTypography.labelMd
                          .copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const _TableHeader(),
          if (sales.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text('Aucune vente pour le moment.',
                    style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            )
          else
            for (var i = 0; i < sales.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, color: AppColors.surfaceContainer),
              _SaleRow(sale: sales[i]),
            ],
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    Widget cell(String t, {TextAlign align = TextAlign.left}) => Text(
          t.toUpperCase(),
          textAlign: align,
          style: AppTypography.labelSm.copyWith(
              color: AppColors.onSecondaryContainer, letterSpacing: 0.5),
        );
    return Container(
      color: AppColors.secondaryContainer.withValues(alpha: .3),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(flex: 4, child: cell('Article / Client')),
          Expanded(flex: 2, child: cell('Heure')),
          Expanded(flex: 3, child: cell('Montant')),
          Expanded(
              flex: 2, child: cell('Statut', align: TextAlign.right)),
        ],
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.sale});

  final RecentSaleView sale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(sale.icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sale.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMd
                              .copyWith(fontWeight: FontWeight.w700)),
                      Text(sale.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(formatRelativeDay(sale.date),
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ),
          Expanded(
            flex: 3,
            child: Text(formatGnf(sale.amount),
                style: AppTypography.labelMd.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: sale.paid
                  ? const StatusPill.paid()
                  : const StatusPill.credit(),
            ),
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
        const SizedBox(height: AppSpacing.lg),
        _AiTipCard(bestSeller: data.bestSeller),
      ],
    );
  }
}

class _WeeklyGrowthCard extends StatelessWidget {
  const _WeeklyGrowthCard({required this.growth});

  final double? growth;

  @override
  Widget build(BuildContext context) {
    final label = growth == null
        ? '—'
        : '${growth! >= 0 ? '+' : ''}${growth!.toStringAsFixed(1)} %';
    return Container(
      height: 192,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A101828), offset: Offset(0, 2), blurRadius: 8),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: .3,
              child: CustomPaint(
                size: const Size(double.infinity, 60),
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
                      style: AppTypography.labelSm.copyWith(
                          color: AppColors.onPrimary.withValues(alpha: .8))),
                  const SizedBox(height: AppSpacing.xs),
                  Text(label,
                      style: AppTypography.headlineMd
                          .copyWith(color: AppColors.onPrimary)),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.onPrimary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Pouls du commerce en temps réel',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary)),
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
    final paint = Paint()..color = AppColors.onPrimary;
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, h * 0.66)
      ..cubicTo(w * .25, h * .16, w * .5, h * .83, w, h * .33)
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

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('À réapprovisionner', style: AppTypography.labelMd),
              if (products.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text('CRITIQUE',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onErrorContainer)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (products.isEmpty)
            Text('Aucun produit à réapprovisionner 👍',
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.onSurfaceVariant))
          else ...[
            for (final p in products.take(3)) _RestockRow(product: p),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () => context.go('/fournisseurs'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
              child: const Text('Commander'),
            ),
          ],
        ],
      ),
    );
  }
}

class _RestockRow extends StatelessWidget {
  const _RestockRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final critical = product.stockQuantity <= 2;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySm),
          ),
          Text(
            'reste ${formatQuantity(product.stockQuantity)}',
            style: AppTypography.labelSm.copyWith(
              color: critical
                  ? AppColors.error
                  : AppColors.onTertiaryFixedVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiTipCard extends StatelessWidget {
  const _AiTipCard({required this.bestSeller});

  final String? bestSeller;

  @override
  Widget build(BuildContext context) {
    final tip = bestSeller != null
        ? '« Concentrez-vous sur $bestSeller cette semaine — '
            'c\'est votre meilleure vente. »'
        : '« Enregistrez vos ventes pour recevoir des conseils '
            'personnalisés sur votre commerce. »';
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(tip,
                textAlign: TextAlign.center,
                style: AppTypography.labelSm.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.md),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text('IA',
                  style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bord en pointillés (carte conseil IA), fidèle à la maquette.
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(AppRadius.xl));
    final path = Path()..addRRect(rrect);
    const dash = 6.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(
            metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
