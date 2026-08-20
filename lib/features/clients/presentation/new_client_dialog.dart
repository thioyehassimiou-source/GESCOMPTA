import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';

import 'package:nmashop/core/theme/app_theme.dart';

class NewClientDialog extends ConsumerStatefulWidget {
  const NewClientDialog({super.key, this.existingClient});

  final Customer? existingClient;

  static Future<void> show(BuildContext context, {Customer? client}) {
    return showDialog(
      context: context,
      builder: (ctx) => NewClientDialog(existingClient: client),
    );
  }

  @override
  ConsumerState<NewClientDialog> createState() => _NewClientDialogState();
}

class _NewClientDialogState extends ConsumerState<NewClientDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingClient?.name);
    _phoneController = TextEditingController(text: widget.existingClient?.phone);
    _addressController = TextEditingController(text: widget.existingClient?.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final db = ref.read(databaseProvider);
    
    if (widget.existingClient == null) {
      // Create new
      await db.into(db.customers).insert(
            CustomersCompanion.insert(
              id: const Uuid().v4(),
              name: name,
              phone: Value(_phoneController.text.trim().isEmpty ? null : _phoneController.text.trim()),
              address: Value(_addressController.text.trim().isEmpty ? null : _addressController.text.trim()),
            ),
          );
    } else {
      // Update existing
      await (db.update(db.customers)..where((c) => c.id.equals(widget.existingClient!.id))).write(
        CustomersCompanion(
          name: Value(name),
          phone: Value(_phoneController.text.trim().isEmpty ? null : _phoneController.text.trim()),
          address: Value(_addressController.text.trim().isEmpty ? null : _addressController.text.trim()),
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.existingClient == null ? 'Client ajouté ✓' : 'Client modifié ✓')),
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
                Icon(Icons.person_add_outlined, color: context.colors.primary),
                const SizedBox(width: AppSpacing.md),
                Text(
                  widget.existingClient == null ? 'Nouveau Client' : 'Modifier le client',
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
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse / Localisation',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              maxLines: 2,
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
