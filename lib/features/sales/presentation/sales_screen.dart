import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/payment_method.dart';
import '../../../core/format/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../stock/application/stock_providers.dart';
import '../../stock/domain/entities/product.dart';
import '../application/sale_cart_controller.dart';
import '../domain/usecases/record_sale.dart';

/// Écran « Vendre » — le workflow central. Toute la logique vit dans le
/// [SaleCartController] ; ce widget se contente d'afficher et de dispatcher.
class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: _ProductPicker()),
          SizedBox(width: AppSpacing.lg),
          SizedBox(width: 360, child: _CartPanel()),
        ],
      ),
    );
  }
}

// ─────────────────────────── Volet produits ───────────────────────────

class _ProductPicker extends ConsumerStatefulWidget {
  const _ProductPicker();

  @override
  ConsumerState<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends ConsumerState<_ProductPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsStreamProvider);
    final cartLines = ref.watch(saleCartControllerProvider).lines;

    // Map productId → quantité dans le panier pour les badges
    final cartQty = {for (final l in cartLines) l.productId: l.quantity};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── En-tête ──
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vendre', style: AppTypography.headlineMd),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Touchez un produit pour l\'ajouter à la vente.',
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Barre de recherche ──
        AppCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search,
                  color: theme.colorScheme.onSurfaceVariant, size: 20),
              hintText: 'Rechercher un produit…',
              hintStyle: AppTypography.bodySm
                  .copyWith(color: AppColors.onSurfaceVariant),
              border: InputBorder.none,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.base),
            ),
            style: AppTypography.bodySm,
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Grille produits ──
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Erreur : $e',
                  style:
                      AppTypography.bodySm.copyWith(color: AppColors.error)),
            ),
            data: (products) {
              final visible = products
                  .where((p) =>
                      p.isActive &&
                      (_query.isEmpty ||
                          p.name.toLowerCase().contains(_query)))
                  .toList();
              if (visible.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.4)),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        products.isEmpty
                            ? 'Aucun produit.\nAjoutez-en dans « Mes produits ».'
                            : 'Aucun produit ne correspond à « $_query ».',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                );
              }
              return GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisExtent: 110,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemCount: visible.length,
                itemBuilder: (_, i) => _ProductTile(
                  product: visible[i],
                  cartQuantity: cartQty[visible[i].id] ?? 0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Tuile produit ───────────────────────────

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product, required this.cartQuantity});

  final Product product;
  final double cartQuantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outOfStock = product.stockQuantity <= 0;
    final inCart = cartQuantity > 0;

    AppChipStatus chipStatus;
    String chipLabel;
    if (outOfStock) {
      chipStatus = AppChipStatus.neutral;
      chipLabel = 'Rupture';
    } else if (product.stockQuantity <= (product.lowStockThreshold > 0
        ? product.lowStockThreshold
        : 3)) {
      chipStatus = AppChipStatus.warning;
      chipLabel = 'Stock bas';
    } else {
      chipStatus = AppChipStatus.success;
      chipLabel = 'En stock';
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: outOfStock
          ? null
          : () => ref
              .read(saleCartControllerProvider.notifier)
              .addProduct(product),
      hoverBorder: !outOfStock,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom produit
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd.copyWith(
                    color: outOfStock
                        ? AppColors.onSurfaceVariant
                        : AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Prix + statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    formatGnf(product.salePrice),
                    style: AppTypography.labelMd.copyWith(
                      color: outOfStock
                          ? AppColors.onSurfaceVariant
                          : AppColors.primary,
                    ),
                  ),
                  AppChip(label: chipLabel, status: chipStatus),
                ],
              ),
            ],
          ),
          // Badge panier (quantité en cours)
          if (inCart)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  formatQuantity(cartQuantity),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Volet panier ───────────────────────────

class _CartPanel extends ConsumerWidget {
  const _CartPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(saleCartControllerProvider);
    final controller = ref.read(saleCartControllerProvider.notifier);

    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── En-tête panier ──
          _CartHeader(isEmpty: state.isEmpty, onClear: controller.clear),

          // ── Lignes ──
          Expanded(
            child: state.isEmpty
                ? _EmptyCartPlaceholder()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.base),
                    itemCount: state.lines.length,
                    separatorBuilder: (_, i) => Divider(
                      height: 1,
                      color: theme.colorScheme.outlineVariant,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                    ),
                    itemBuilder: (_, i) => _CartLineTile(index: i),
                  ),
          ),

          // ── Pied : paiement + total + bouton ──
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PaymentSelector(state: state, controller: controller),
                const SizedBox(height: AppSpacing.md),

                // Total
                Row(
                  children: [
                    Text('Total',
                        style: AppTypography.labelMd
                            .copyWith(color: AppColors.onSurfaceVariant)),
                    const Spacer(),
                    Text(
                      formatGnf(state.total),
                      style: AppTypography.headlineMd
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Avertissement stock
                if (state.hasStockIssue) ...[
                  const AppChip(
                    label: 'Quantité insuffisante en stock',
                    status: AppChipStatus.error,
                  ),
                  const SizedBox(height: AppSpacing.base),
                ],

                // Bouton enregistrer
                _SubmitButton(state: state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── En-tête du panneau panier ──
class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.isEmpty, required this.onClear});

  final bool isEmpty;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Text('Vente en cours',
                style: AppTypography.labelMd),
          ),
          if (!isEmpty)
            AppButton.secondary(
              label: 'Vider',
              icon: Icons.delete_outline,
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}

// ── État vide ──
class _EmptyCartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Panier vide',
              style: AppTypography.labelMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Cliquez sur un produit à gauche\npour l\'ajouter.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.outlineVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bouton enregistrer ──
class _SubmitButton extends ConsumerWidget {
  const _SubmitButton({required this.state});
  final SaleCartState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disabled = state.isEmpty || state.submitting || state.hasStockIssue;

    return SizedBox(
      width: double.infinity,
      child: AppButton(
        icon: state.submitting ? null : Icons.check_circle_outline,
        label: state.submitting ? 'Enregistrement…' : 'Enregistrer la vente',
        onPressed: disabled ? null : () => _submit(context, ref),
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final result =
        await ref.read(saleCartControllerProvider.notifier).submit();
    if (!context.mounted) return;

    switch (result) {
      case RecordSaleSuccess(:final sale):
        messenger.showSnackBar(SnackBar(
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          content: Text(
            sale.isCredit
                ? '✅ Vente (${sale.reference}) — crédit de ${formatGnf(sale.creditAmount)} noté.'
                : '✅ Vente enregistrée (${sale.reference}).',
            style: AppTypography.bodySm.copyWith(color: AppColors.onPrimaryContainer),
          ),
        ));
      case RecordSaleFailure(:final error):
        messenger.showSnackBar(SnackBar(
          backgroundColor: AppColors.errorContainer,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          content: Text(
            error.message,
            style: AppTypography.bodySm.copyWith(color: AppColors.onErrorContainer),
          ),
        ));
    }
  }
}

// ─────────────────────────── Ligne de panier ───────────────────────────

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final line = ref.watch(saleCartControllerProvider).lines[index];
    final controller = ref.read(saleCartControllerProvider.notifier);
    final hasIssue = line.exceedsStock;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.base),
      child: Row(
        children: [
          // Icône produit
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(Icons.inventory_2_outlined,
                size: 16,
                color: hasIssue
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.base),

          // Nom + prix unitaire
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd,
                ),
                Text(
                  '${formatGnf(line.unitPrice)} / ${line.unit}',
                  style: AppTypography.labelSm.copyWith(
                    color: hasIssue
                        ? theme.colorScheme.error
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Contrôles quantité
          _QuantityControl(
            quantity: line.quantity,
            available: line.availableStock,
            onDecrement: () =>
                controller.setQuantity(index, line.quantity - 1),
            onIncrement: () =>
                controller.setQuantity(index, line.quantity + 1),
          ),

          // Sous-total
          SizedBox(
            width: 90,
            child: Text(
              formatAmount(line.lineTotal),
              textAlign: TextAlign.right,
              style: AppTypography.labelMd.copyWith(
                color: hasIssue ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.available,
    required this.onDecrement,
    required this.onIncrement,
  });

  final double quantity;
  final double available;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atMax = quantity >= available;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(icon: Icons.remove, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              formatQuantity(quantity),
              style: AppTypography.labelMd,
            ),
          ),
          _QtyBtn(
              icon: Icons.add,
              onTap: atMax ? null : onIncrement,
              disabled: atMax),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, this.onTap, this.disabled = false});
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon,
            size: 16,
            color: disabled
                ? AppColors.outlineVariant
                : AppColors.onSurface),
      ),
    );
  }
}

// ─────────────────────────── Sélecteur de paiement ───────────────────────────

class _PaymentSelector extends StatelessWidget {
  const _PaymentSelector({required this.state, required this.controller});

  final SaleCartState state;
  final SaleCartController controller;

  static const _methods = {
    PaymentMethod.cash: (Icons.payments_outlined, 'Espèces'),
    PaymentMethod.mobileMoney: (Icons.phone_android_outlined, 'Mobile Money'),
    PaymentMethod.bank: (Icons.account_balance_outlined, 'Banque'),
    PaymentMethod.credit: (Icons.schedule_outlined, 'Crédit'),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mode de paiement',
            style:
                AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.base),
        Wrap(
          spacing: AppSpacing.base,
          runSpacing: AppSpacing.base,
          children: [
            for (final entry in _methods.entries)
              _PaymentChip(
                icon: entry.value.$1,
                label: entry.value.$2,
                selected: state.method == entry.key,
                onTap: () => controller.setMethod(entry.key),
              ),
          ],
        ),
        if (state.isCredit) ...[
          const SizedBox(height: AppSpacing.base),
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline, size: 18),
              labelText: 'Nom du client',
              hintText: 'Ex : Mamadou Diallo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              isDense: true,
            ),
            style: AppTypography.bodySm,
            onChanged: controller.setCustomerName,
          ),
        ],
      ],
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color:
                    selected ? AppColors.onPrimary : AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color:
                    selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
