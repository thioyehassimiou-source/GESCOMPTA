import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../core/format/formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/product_thumbnail.dart';

import '../../../../features/stock/application/stock_providers.dart';
import '../../../../features/stock/domain/entities/product.dart';
import '../data/repositories/drift_order_repository.dart';

import 'package:nmashop/core/theme/app_theme.dart';

class _OrderLine {
  _OrderLine({required this.product});
  final Product product;
  int quantity = 1;
  int get total => product.salePrice * quantity;
}

class NewOrderDialog extends ConsumerStatefulWidget {
  const NewOrderDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const NewOrderDialog(),
    );
  }

  @override
  ConsumerState<NewOrderDialog> createState() => _NewOrderDialogState();
}

class _NewOrderDialogState extends ConsumerState<NewOrderDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  DeliveryType _deliveryType = DeliveryType.pickup;
  final List<_OrderLine> _lines = [];
  bool _isSaving = false;
  String _productSearch = '';

  int get _total => _lines.fold(0, (s, l) => s + l.total);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _addProduct(Product p) {
    setState(() {
      final idx = _lines.indexWhere((l) => l.product.id == p.id);
      if (idx >= 0) {
        _lines[idx].quantity++;
      } else {
        _lines.add(_OrderLine(product: p));
      }
    });
  }

  void _removeLine(int idx) => setState(() => _lines.removeAt(idx));

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom du client est obligatoire')),
      );
      return;
    }
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un produit')),
      );
      return;
    }
    if (_deliveryType == DeliveryType.delivery && _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('L\'adresse de livraison est obligatoire')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(orderRepositoryProvider).insertOrder(
            customerName: name,
            customerPhone: phone.isEmpty ? null : phone,
            deliveryType: _deliveryType,
            deliveryAddress: _deliveryType == DeliveryType.delivery
                ? _addressCtrl.text.trim()
                : null,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            lines: _lines.map((l) => OrderLine(
                  productId: l.product.id,
                  label: l.product.name,
                  unitPrice: l.product.salePrice,
                  quantity: l.quantity,
                )).toList(),
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande enregistrée ✓'),
            backgroundColor: AppColors.brandEmerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: context.colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const indigo = Color(0xFF6366F1);
    final productsAsync = ref.watch(productsStreamProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 900,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: indigo,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('Nouvelle Commande', style: AppTypography.labelMd.copyWith(color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Corps (2 colonnes)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Colonne gauche : Infos client + catalogue ─────────────
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: context.colors.surfaceContainerLowest,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── CARTE 1 : Client & Livraison ───
                            AppCard(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline, size: 20, color: indigo),
                                      const SizedBox(width: 8),
                                      Text('Informations Client', style: AppTypography.labelMd.copyWith(color: indigo)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _nameCtrl,
                                    decoration: InputDecoration(
                                      labelText: 'Nom du client *',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      isDense: true,
                                      prefixIcon: const Icon(Icons.person, size: 18),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText: 'Téléphone',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      isDense: true,
                                      prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text('Mode de livraison *', style: AppTypography.labelSm),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: SegmentedButton<DeliveryType>(
                                      style: SegmentedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      segments: const [
                                        ButtonSegment(
                                          value: DeliveryType.pickup,
                                          label: Text('Retrait boutique'),
                                          icon: Icon(Icons.storefront_outlined, size: 16),
                                        ),
                                        ButtonSegment(
                                          value: DeliveryType.delivery,
                                          label: Text('Livraison à domicile'),
                                          icon: Icon(Icons.local_shipping_outlined, size: 16),
                                        ),
                                      ],
                                      selected: {_deliveryType},
                                      onSelectionChanged: (s) => setState(() => _deliveryType = s.first),
                                    ),
                                  ),
                                  if (_deliveryType == DeliveryType.delivery) ...[
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _addressCtrl,
                                      decoration: InputDecoration(
                                        labelText: 'Adresse de livraison *',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        isDense: true,
                                        prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _noteCtrl,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      labelText: 'Note / Instructions',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      isDense: true,
                                      alignLabelWithHint: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ─── CARTE 2 : Catalogue Produits ───
                            AppCard(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.inventory_2_outlined, size: 20, color: indigo),
                                      const SizedBox(width: 8),
                                      Text('Ajouter des produits', style: AppTypography.labelMd.copyWith(color: indigo)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _searchCtrl,
                                    onChanged: (v) => setState(() => _productSearch = v.trim().toLowerCase()),
                                    decoration: InputDecoration(
                                      hintText: 'Rechercher un produit…',
                                      prefixIcon: const Icon(Icons.search, size: 18),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      filled: true,
                                      fillColor: context.colors.surfaceContainerLowest,
                                      isDense: true,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  productsAsync.when(
                            loading: () => const CircularProgressIndicator(),
                            error: (e, _) => Text('Erreur: $e'),
                            data: (products) {
                              final visible = products.where((p) =>
                                  p.isActive &&
                                  (_productSearch.isEmpty ||
                                      p.name.toLowerCase().contains(_productSearch))).toList();

                              return Column(
                                children: visible.map((p) {
                                  return ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    leading: ProductThumbnail(
                                      imageUrl: p.imageUrl,
                                      size: 36,
                                      borderRadius: 8,
                                      fallbackColor: indigo,
                                    ),
                                    title: Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    subtitle: Text(formatGnf(p.salePrice), style: const TextStyle(fontSize: 12)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: indigo),
                                      onPressed: () => _addProduct(p),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const VerticalDivider(width: 1),

                  // ── Colonne droite : Récapitulatif commande ───────────────
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: context.colors.surface,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.white,
                            child: Row(
                              children: [
                                Icon(Icons.shopping_cart_checkout, size: 20, color: context.colors.onSurface),
                                SizedBox(width: 8),
                                Text('Récapitulatif', style: AppTypography.labelMd),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: _lines.isEmpty
                                ? Center(
                                    child: Text(
                                      'Aucun produit ajouté.\nSélectionnez des produits à gauche.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 12),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _lines.length,
                                    separatorBuilder: (ctx, idx) => const Divider(height: 1),
                                    itemBuilder: (ctx, i) {
                                      final line = _lines[i];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            ProductThumbnail(
                                              imageUrl: line.product.imageUrl,
                                              size: 40,
                                              borderRadius: 8,
                                              fallbackColor: const Color(0xFF6366F1),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(line.product.name,
                                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                                  Text(formatGnf(line.product.salePrice),
                                                      style: TextStyle(fontSize: 11, color: context.colors.onSurfaceVariant)),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (line.quantity > 1) {
                                                        line.quantity--;
                                                      } else {
                                                        _lines.removeAt(i);
                                                      }
                                                    });
                                                  },
                                                ),
                                                Text('${line.quantity}',
                                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                                IconButton(
                                                  icon: const Icon(Icons.add_circle_outline, size: 18, color: indigo),
                                                  onPressed: () => setState(() => line.quantity++),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 80,
                                              child: Text(
                                                formatGnf(line.total),
                                                textAlign: TextAlign.end,
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete_outline, size: 16, color: context.colors.error),
                                              onPressed: () => _removeLine(i),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                    Text(
                                      formatGnf(_total),
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: indigo),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: _isSaving ? null : _save,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: indigo,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: _isSaving
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Text('Enregistrer la commande', style: TextStyle(fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
