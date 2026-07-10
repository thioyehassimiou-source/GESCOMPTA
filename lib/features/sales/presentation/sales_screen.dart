import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/payment_method.dart';
import '../../../core/format/formatters.dart';
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
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: _ProductPicker()),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _CartPanel()),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vendre', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Touchez un produit pour l\'ajouter à la vente.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Rechercher un produit…',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur : $e')),
            data: (products) {
              final visible = products
                  .where((p) =>
                      p.isActive &&
                      (_query.isEmpty ||
                          p.name.toLowerCase().contains(_query)))
                  .toList();
              if (visible.isEmpty) {
                return Center(
                  child: Text(
                    products.isEmpty
                        ? 'Aucun produit. Ajoutez-en dans « Mes produits ».'
                        : 'Aucun produit ne correspond.',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                );
              }
              return GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: 96,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: visible.length,
                itemBuilder: (_, i) => _ProductTile(product: visible[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final outOfStock = product.stockQuantity <= 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: outOfStock
            ? null
            : () =>
                ref.read(saleCartControllerProvider.notifier).addProduct(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatGnf(product.salePrice),
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary)),
                  Text(
                    outOfStock
                        ? 'rupture'
                        : '${formatQuantity(product.stockQuantity)} ${product.unit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: outOfStock
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
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

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                const SizedBox(width: 8),
                Text('Vente en cours', style: theme.textTheme.titleMedium),
                const Spacer(),
                if (!state.isEmpty)
                  TextButton(
                    onPressed: controller.clear,
                    child: const Text('Vider'),
                  ),
              ],
            ),
            const Divider(),
            Expanded(
              child: state.isEmpty
                  ? Center(
                      child: Text('Panier vide',
                          style:
                              TextStyle(color: theme.colorScheme.outline)),
                    )
                  : ListView.builder(
                      itemCount: state.lines.length,
                      itemBuilder: (_, i) => _CartLineTile(index: i),
                    ),
            ),
            const Divider(),
            _PaymentSelector(state: state, controller: controller),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Total', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(formatGnf(state.total),
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed:
                  state.isEmpty || state.submitting || state.hasStockIssue
                      ? null
                      : () => _submit(context, ref),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              icon: state.submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline),
              label: Text(state.submitting
                  ? 'Enregistrement…'
                  : 'Enregistrer la vente'),
            ),
            if (state.hasStockIssue)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Une quantité dépasse le stock disponible.',
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
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
          backgroundColor: Colors.green.shade700,
          content: Text(
            sale.isCredit
                ? '✅ Vente enregistrée (${sale.reference}) — '
                    'crédit de ${formatGnf(sale.creditAmount)} noté.'
                : '✅ Vente enregistrée avec succès (${sale.reference}).',
          ),
        ));
      case RecordSaleFailure(:final error):
        messenger.showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(error.message),
        ));
    }
  }
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final line = ref.watch(saleCartControllerProvider).lines[index];
    final controller = ref.read(saleCartControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  '${formatGnf(line.unitPrice)} × ${formatQuantity(line.quantity)} ${line.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: line.exceedsStock
                        ? theme.colorScheme.error
                        : theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () =>
                controller.setQuantity(index, line.quantity - 1),
          ),
          Text(formatQuantity(line.quantity)),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () =>
                controller.setQuantity(index, line.quantity + 1),
          ),
          SizedBox(
            width: 96,
            child: Text(formatGnf(line.lineTotal),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PaymentSelector extends StatelessWidget {
  const _PaymentSelector({required this.state, required this.controller});

  final SaleCartState state;
  final SaleCartController controller;

  static const _labels = {
    PaymentMethod.cash: 'Espèces',
    PaymentMethod.mobileMoney: 'Mobile Money',
    PaymentMethod.bank: 'Banque',
    PaymentMethod.credit: 'Crédit',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paiement', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final entry in _labels.entries)
              ChoiceChip(
                label: Text(entry.value),
                selected: state.method == entry.key,
                onSelected: (_) => controller.setMethod(entry.key),
              ),
          ],
        ),
        if (state.isCredit)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
                labelText: 'Nom du client (crédit)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: controller.setCustomerName,
            ),
          ),
      ],
    );
  }
}
