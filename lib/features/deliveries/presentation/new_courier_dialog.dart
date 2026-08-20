import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/database/tables/deliveries.dart';

import 'package:nmashop/core/theme/app_theme.dart';

class NewCourierDialog extends ConsumerStatefulWidget {
  const NewCourierDialog({super.key, this.existingCourier});

  final Courier? existingCourier;

  static Future<void> show(BuildContext context, {Courier? courier}) {
    return showDialog(
      context: context,
      builder: (ctx) => NewCourierDialog(existingCourier: courier),
    );
  }

  @override
  ConsumerState<NewCourierDialog> createState() => _NewCourierDialogState();
}

class _NewCourierDialogState extends ConsumerState<NewCourierDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  VehicleType _selectedType = VehicleType.moto;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingCourier?.name);
    _phoneController = TextEditingController(text: widget.existingCourier?.phone);
    if (widget.existingCourier != null) {
      _selectedType = widget.existingCourier!.vehicleType;
      _isActive = widget.existingCourier!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final db = ref.read(databaseProvider);
    final phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    
    if (widget.existingCourier == null) {
      // Create new
      await db.into(db.couriers).insert(
            CouriersCompanion.insert(
              id: const Uuid().v4(),
              name: name,
              phone: Value(phone),
              vehicleType: Value(_selectedType),
              isActive: Value(_isActive),
            ),
          );
    } else {
      // Update existing
      await (db.update(db.couriers)..where((c) => c.id.equals(widget.existingCourier!.id))).write(
        CouriersCompanion(
          name: Value(name),
          phone: Value(phone),
          vehicleType: Value(_selectedType),
          isActive: Value(_isActive),
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.existingCourier == null ? 'Livreur ajouté ✓' : 'Livreur modifié ✓')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sports_motorsports_outlined, color: context.colors.primary),
                const SizedBox(width: AppSpacing.md),
                Text(
                  widget.existingCourier == null ? 'Nouveau Livreur' : 'Modifier le livreur',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom complet *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<VehicleType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Véhicule',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_bike_outlined),
              ),
              items: VehicleType.values.map((v) {
                return DropdownMenuItem(
                  value: v,
                  child: Text(v.label),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              title: const Text('Actif (disponible)'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
              activeThumbColor: context.colors.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Enregistrer',
                onPressed: _save,
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
