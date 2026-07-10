import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_metric_card.dart';
import '../../../core/widgets/app_table.dart';
import '../application/stock_providers.dart';
import '../domain/entities/product.dart';
import '../domain/entities/product_draft.dart';
import '../domain/usecases/save_product_result.dart';

enum StockStatus { inStock, reorder, critical, out }

StockStatus _statusOf(Product p) {
  if (p.stockQuantity <= 0) return StockStatus.out;
  final t = p.lowStockThreshold;
  if (t > 0 && p.stockQuantity <= t * 0.5) return StockStatus.critical;
  if (t > 0 && p.stockQuantity <= t) return StockStatus.reorder;
  return StockStatus.inStock;
}

AppChipStatus _chipStatusOf(StockStatus status) {
  switch (status) {
    case StockStatus.critical: return AppChipStatus.error;
    case StockStatus.reorder: return AppChipStatus.warning;
    case StockStatus.inStock: return AppChipStatus.success;
    case StockStatus.out: return AppChipStatus.neutral;
  }
}

String _statusLabelOf(StockStatus status) {
  switch (status) {
    case StockStatus.critical: return 'Stock Critique';
    case StockStatus.reorder: return 'À Recommander';
    case StockStatus.inStock: return 'En Stock';
    case StockStatus.out: return 'Rupture';
  }
}

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  StockStatus? _statusFilter;
  int _page = 0;
  final _selected = <String>{};

  List<Product> _applyFilter(List<Product> all) {
    if (_statusFilter == null) return all;
    if (_statusFilter == StockStatus.reorder) {
      return all
          .where((p) =>
              _statusOf(p) == StockStatus.reorder ||
              _statusOf(p) == StockStatus.critical)
          .toList();
    }
    return all.where((p) => _statusOf(p) == _statusFilter).toList();
  }

  void _openDialog(Product? product) {
    showDialog<void>(
      context: context,
      builder: (_) => _ProductDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.barcode_reader, size: 28),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (all) {
          final filtered = _applyFilter(all);
          final pageCount = (filtered.length / 10).ceil().clamp(1, 9999);
          if (_page >= pageCount) _page = pageCount - 1;
          final start = _page * 10;
          final pageItems = filtered.skip(start).take(10).toList(growable: false);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(all.length),
                    const SizedBox(height: AppSpacing.lg),
                    _buildFilterBar(filtered.length, start, pageItems.length),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTableCard(pageItems, pageCount),
                    const SizedBox(height: AppSpacing.xl),
                    _buildInsights(all),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(int activeCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produits', style: AppTypography.headlineMd),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Gestion de $activeCount produits actifs.',
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        Row(
          children: [
            AppButton.secondary(
              icon: Icons.file_download_outlined,
              label: 'Exporter',
              onPressed: () {},
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              icon: Icons.add,
              label: 'Nouveau Produit',
              onPressed: () => _openDialog(null),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar(int total, int start, int length) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Text('FILTRES :', style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(width: AppSpacing.sm),
          _buildDropdown<String>('Toutes Catégories', ['Toutes Catégories']),
          const SizedBox(width: AppSpacing.sm),
          _buildDropdown<StockStatus?>(_statusFilter, [null, StockStatus.inStock, StockStatus.reorder, StockStatus.out], (s) => s == null ? 'Tous les Statuts' : _statusLabelOf(s)),
          Container(
            width: 1,
            height: 32,
            color: AppColors.outlineVariant,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          const Spacer(),
          Text('Affichage de ${length == 0 ? 0 : start + 1}-${start + length} sur $total', style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(T value, List<T> items, [String Function(T)? labelOf]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.onSurface),
          style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
          items: items.map((it) => DropdownMenuItem(
            value: it,
            child: Text(labelOf != null ? labelOf(it) : '$it'),
          )).toList(),
          onChanged: (v) {
            if (v is StockStatus? && labelOf != null) {
              setState(() {
                _statusFilter = v;
                _page = 0;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTableCard(List<Product> items, int pageCount) {
    if (items.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(64),
        child: const Center(child: Text('Aucun produit trouvé.')),
      );
    }
    
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: AppTable(
              columns: [
                DataColumn(label: Checkbox(value: false, onChanged: (_) {})),
                const DataColumn(label: Text('NOM')),
                const DataColumn(label: Text('CATÉGORIE')),
                const DataColumn(label: Text('NIVEAU DE STOCK'), numeric: true),
                const DataColumn(label: Text('PRIX (GNF)'), numeric: true),
                const DataColumn(label: Text('STATUT')),
                const DataColumn(label: Text('ACTIONS')),
              ],
              rows: items.map((p) {
                final status = _statusOf(p);
                final out = status == StockStatus.out;
                
                return DataRow(
                  cells: [
                    DataCell(Checkbox(value: _selected.contains(p.id), onChanged: (_) {})),
                    DataCell(
                      Row(
                        children: [
                          Opacity(
                            opacity: out ? 0.5 : 1.0,
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, color: AppColors.onSurfaceVariant, size: 20),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(p.name, style: AppTypography.labelMd),
                              Text('Réf: ${p.reference ?? p.id.substring(0,6)}', style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const DataCell(Text('Générale', style: AppTypography.bodySm)),
                    DataCell(AppBadge(text: '${formatQuantity(p.stockQuantity)} unités', status: _chipStatusOf(status))),
                    DataCell(Text(formatAmount(p.salePrice), style: AppTypography.labelMd)),
                    DataCell(AppChip(label: _statusLabelOf(status), status: _chipStatusOf(status))),
                    DataCell(IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _openDialog(p))),
                  ],
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton.secondary(icon: Icons.chevron_left, label: 'Précédent', onPressed: _page > 0 ? () => setState(() => _page--) : null),
                Text('Page ${_page + 1} sur $pageCount', style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                AppButton.secondary(icon: Icons.chevron_right, label: 'Suivant', onPressed: _page < pageCount - 1 ? () => setState(() => _page++) : null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(List<Product> products) {
    final inventoryValue = products.fold<int>(0, (sum, p) {
      final cost = p.weightedAverageCost > 0 ? p.weightedAverageCost : p.purchasePrice.toDouble();
      return sum + (cost * p.stockQuantity).round();
    });
    final restock = products.where((p) => p.isActive && _statusOf(p) != StockStatus.inStock).length;

    return Row(
      children: [
        Expanded(
          child: AppMetricCard(
            title: 'Valeur du Stock',
            value: formatAmount(inventoryValue),
            suffix: 'GNF',
            icon: Icons.inventory_2,
            trendText: '+4.2% depuis le mois dernier',
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: AppMetricCard(
            title: 'Alertes de Réappro.',
            value: '$restock',
            suffix: 'Produits',
            icon: Icons.notification_important,
            variant: AppMetricVariant.error,
            actionWidget: Text('Voir la liste critique →', style: AppTypography.labelSm.copyWith(color: AppColors.primary)),
          ),
        ),

      ],
    );
  }
}

// ─────────────────────────── Dialogue ajout / édition ───────────────────────────
class _ProductDialog extends ConsumerStatefulWidget {
  const _ProductDialog({required this.product});
  final Product? product;

  @override
  ConsumerState<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends ConsumerState<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _reference;
  late final TextEditingController _unit;
  late final TextEditingController _purchase;
  late final TextEditingController _sale;
  late final TextEditingController _stock;
  late final TextEditingController _threshold;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _reference = TextEditingController(text: p?.reference ?? '');
    _unit = TextEditingController(text: p?.unit ?? 'pièce');
    _purchase = TextEditingController(text: '${p?.purchasePrice ?? 0}');
    _sale = TextEditingController(text: '${p?.salePrice ?? 0}');
    _stock = TextEditingController(text: formatQuantity(p?.stockQuantity ?? 0));
    _threshold = TextEditingController(text: formatQuantity(p?.lowStockThreshold ?? 0));
  }

  @override
  void dispose() {
    for (final c in [_name, _reference, _unit, _purchase, _sale, _stock, _threshold]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final draft = ProductDraft(
      name: _name.text.trim(),
      reference: _reference.text.trim().isEmpty ? null : _reference.text.trim(),
      unit: _unit.text.trim().isEmpty ? 'pièce' : _unit.text.trim(),
      purchasePrice: int.tryParse(_purchase.text.trim()) ?? 0,
      salePrice: int.tryParse(_sale.text.trim()) ?? 0,
      stockQuantity:
          double.tryParse(_stock.text.trim().replaceAll(',', '.')) ?? 0,
      lowStockThreshold:
          double.tryParse(_threshold.text.trim().replaceAll(',', '.')) ?? 0,
    );

    final result = _isEdit
        ? await ref
            .read(updateProductUseCaseProvider)
            .call(widget.product!.id, draft)
        : await ref.read(addProductUseCaseProvider).call(draft);

    if (!mounted) return;
    switch (result) {
      case SaveProductSuccess():
        Navigator.of(context).pop();
      case SaveProductFailure(:final error):
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(error.message),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Modifier Produit' : 'Ajouter Produit', style: AppTypography.headlineMd),
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nom *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(children: [
                  Expanded(child: TextFormField(controller: _reference, decoration: const InputDecoration(labelText: 'Réf'))),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: TextFormField(controller: _unit, decoration: const InputDecoration(labelText: 'Unité'))),
                ]),
                const SizedBox(height: AppSpacing.sm),
                Row(children: [
                  Expanded(child: TextFormField(controller: _purchase, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Achat (GNF)'))),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: TextFormField(controller: _sale, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Vente (GNF)'))),
                ]),
                const SizedBox(height: AppSpacing.sm),
                Row(children: [
                  Expanded(child: TextFormField(controller: _stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock'))),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: TextFormField(controller: _threshold, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Seuil d\'alerte'))),
                ]),
              ],
            ),
          ),
        ),
      ),
      actions: [
        AppButton.secondary(label: 'Annuler', onPressed: _saving ? null : () => Navigator.of(context).pop()),
        AppButton(label: 'Enregistrer', onPressed: _saving ? null : _save),
      ],
    );
  }
}
