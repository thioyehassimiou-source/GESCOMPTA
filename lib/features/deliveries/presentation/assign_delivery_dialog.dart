import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../application/deliveries_providers.dart';
import '../../../core/database/tables/deliveries.dart';

import 'package:nmashop/core/theme/app_theme.dart';

class AssignDeliveryDialog extends ConsumerStatefulWidget {
  const AssignDeliveryDialog({super.key, required this.order});

  final Order order;

  static Future<void> show(BuildContext context, {required Order order}) {
    return showDialog(
      context: context,
      builder: (ctx) => AssignDeliveryDialog(order: order),
    );
  }

  @override
  ConsumerState<AssignDeliveryDialog> createState() => _AssignDeliveryDialogState();
}

class _AssignDeliveryDialogState extends ConsumerState<AssignDeliveryDialog> {
  String? _selectedCourierId;
  final TextEditingController _feeController = TextEditingController(text: '0');
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _feeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _assign() async {
    if (_selectedCourierId == null) return;
    final fee = int.tryParse(_feeController.text.trim()) ?? 0;

    await ref.read(deliveriesServiceProvider).assignDelivery(
      orderId: widget.order.id,
      courierId: _selectedCourierId!,
      deliveryFee: fee,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livreur assigné et expédition créée ✓')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final couriersAsync = ref.watch(couriersProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: couriersAsync.when(
          loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SizedBox(height: 100, child: Center(child: Text('Erreur: $e'))),
          data: (couriers) {
            final activeCouriers = couriers.where((c) => c.isActive).toList();
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.delivery_dining_outlined, color: context.colors.primary),
                    const SizedBox(width: AppSpacing.md),
                    const Text(
                      'Assigner un Livreur',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Commande : ${widget.order.reference}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Client : ${widget.order.customerName}', style: TextStyle(color: context.colors.onSurfaceVariant)),
                if (widget.order.deliveryAddress != null)
                  Text('Adresse : ${widget.order.deliveryAddress}', style: TextStyle(color: context.colors.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xl),
                
                if (activeCouriers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Aucun livreur actif disponible. Veuillez en ajouter un dans l\'onglet Livreurs.', style: TextStyle(color: Colors.red)),
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCourierId,
                    decoration: const InputDecoration(
                      labelText: 'Choisir le Livreur *',
                      border: OutlineInputBorder(),
                    ),
                    items: activeCouriers.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.name} (${c.vehicleType == VehicleType.moto ? 'Moto' : 'Véhicule'})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCourierId = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _feeController,
                    decoration: const InputDecoration(
                      labelText: 'Frais dus au livreur (GNF)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Instructions spéciales',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note_alt_outlined),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: 'Confirmer l\'expédition',
                      onPressed: _selectedCourierId == null ? null : _assign,
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
