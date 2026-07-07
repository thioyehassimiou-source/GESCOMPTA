import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_table.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final _purchases = <Map<String, dynamic>>[
    {
      'id': '#PUR-8821',
      'initials': 'SM',
      'supplier': 'SOCOMA S.A.',
      'date': '24 Oct 2023',
      'amount': '2.150.000 GNF',
      'status': AppChipStatus.error,
      'statusLabel': 'En attente'
    },
    {
      'id': '#PUR-8819',
      'initials': 'EB',
      'supplier': 'Ets. Barry',
      'date': '22 Oct 2023',
      'amount': '1.200.000 GNF',
      'status': AppChipStatus.success,
      'statusLabel': 'Payé'
    },
    {
      'id': '#PUR-8815',
      'initials': 'GT',
      'supplier': 'Guinée Tech',
      'date': '20 Oct 2023',
      'amount': '850.000 GNF',
      'status': AppChipStatus.success,
      'statusLabel': 'Payé'
    },
    {
      'id': '#PUR-8812',
      'initials': 'SM',
      'supplier': 'SOCOMA S.A.',
      'date': '18 Oct 2023',
      'amount': '5.400.000 GNF',
      'status': AppChipStatus.neutral,
      'statusLabel': 'Partiel'
    },
    {
      'id': '#PUR-8809',
      'initials': 'EB',
      'supplier': 'Ets. Barry',
      'date': '15 Oct 2023',
      'amount': '3.200.000 GNF',
      'status': AppChipStatus.success,
      'statusLabel': 'Payé'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBentoCards(),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _buildPrioritySuppliers(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildDebtExposureChart(),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      flex: 8,
                      child: _buildRecentPurchases(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBentoCards() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Dû',
                          style: AppTypography.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant)),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: const Icon(Icons.account_balance_wallet,
                            color: AppColors.error, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  RichText(
                    text: TextSpan(
                      text: '15.420.000 ',
                      style: AppTypography.headlineLg.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'GNF',
                          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: AppColors.error, size: 18),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Hausse de 8% depuis le mois dernier',
                          style: AppTypography.bodySm.copyWith(color: AppColors.error)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: const [
                  BoxShadow(color: Color(0x26006054), offset: Offset(0, 4), blurRadius: 12)
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -60,
                    bottom: -60,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Centre d\'Approvisionnement',
                              style: AppTypography.headlineMd.copyWith(color: AppColors.onPrimary)),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Gérez vos entrées de stock et soldez\nvos factures en attente facilement.',
                            style: AppTypography.bodySm.copyWith(color: AppColors.primaryFixed.withValues(alpha: 0.9)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Nouvel Achat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryFixed,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.history, size: 20),
                            label: const Text('Voir les Rapports'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySuppliers() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FOURNISSEURS PRIORITAIRES',
                  style: AppTypography.labelMd.copyWith(
                      letterSpacing: 0.5, color: AppColors.onSurface)),
              Text('Voir tout',
                  style: AppTypography.labelSm.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSupplierItem('SM', 'SOCOMA S.A.', 'Fournitures Industrielles', '4.5M GNF', 'Échéance : 3j', AppColors.tertiaryFixed, AppColors.onTertiaryFixedVariant, AppColors.error),
          const SizedBox(height: AppSpacing.sm),
          _buildSupplierItem('GT', 'Guinée Tech', 'Électronique', '0 GNF', 'À jour', AppColors.secondaryContainer, AppColors.onSecondaryContainer, AppColors.onSurfaceVariant),
          const SizedBox(height: AppSpacing.sm),
          _buildSupplierItem('EB', 'Ets. Barry', 'Marchandises de Gros', '10.9M GNF', 'En retard', AppColors.primaryFixed, AppColors.primary, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildSupplierItem(String initials, String name, String category, String amount, String due, Color bg, Color fg, Color amountColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Center(
              child: Text(initials,
                  style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.labelMd),
                Text(category.toUpperCase(),
                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppTypography.labelMd.copyWith(color: amountColor)),
              Text(due, style: TextStyle(fontSize: 10, color: amountColor == AppColors.error ? AppColors.onSurfaceVariant : AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebtExposureChart() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SizedBox(
        height: 250,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EXPOSITION À LA DETTE',
                    style: AppTypography.labelMd.copyWith(letterSpacing: 0.5)),
                Text('Projections des sorties d\'argent mensuelles',
                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildChartBar(0.25, AppColors.secondaryContainer),
                    _buildChartBar(0.40, AppColors.secondaryContainer),
                    _buildChartBar(0.80, AppColors.primaryContainer),
                    _buildChartBar(0.50, AppColors.secondaryContainer),
                    _buildChartBar(0.66, AppColors.secondaryContainer),
                    _buildChartBar(1.0, AppColors.errorContainer),
                  ],
                ),
              ],
            ),
            Center(
              child: Text('DONNÉES',
                  style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface.withValues(alpha: 0.05))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(double heightFactor, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: FractionallySizedBox(
          heightFactor: heightFactor,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPurchases() {
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Achats Récents', style: AppTypography.headlineMd),
                    Text('Suivi de vos acquisitions de stock sur les 30 derniers jours',
                        style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(icon: const Icon(Icons.download), onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceContainerHigh),
          AppTable(
            columns: const [
              DataColumn(label: Text('ID ACHAT')),
              DataColumn(label: Text('FOURNISSEUR')),
              DataColumn(label: Text('DATE')),
              DataColumn(label: Text('MONTANT'), numeric: true),
              DataColumn(label: Text('STATUT')),
              DataColumn(label: Text('')),
            ],
            rows: _purchases.map((p) {
              return DataRow(
                cells: [
                  DataCell(Text(p['id'], style: AppTypography.labelMd.copyWith(color: AppColors.primary))),
                  DataCell(
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Center(
                            child: Text(p['initials'],
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(p['supplier'], style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  DataCell(Text(p['date'], style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant))),
                  DataCell(Text(p['amount'], style: AppTypography.labelMd)),
                  DataCell(AppChip(label: p['statusLabel'], status: p['status'])),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const Divider(height: 1, color: AppColors.surfaceContainerHigh),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            color: AppColors.surfaceContainerLow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Affichage de 5 sur 42 achats',
                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                Row(
                  children: [
                    AppButton.secondary(label: 'Précédent', onPressed: null),
                    const SizedBox(width: AppSpacing.xs),
                    AppButton.secondary(label: 'Suivant', onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
