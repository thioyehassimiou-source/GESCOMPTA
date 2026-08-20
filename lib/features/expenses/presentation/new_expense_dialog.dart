import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../application/expense_providers.dart';
import '../data/repositories/drift_expense_repository.dart';

import 'package:nmashop/core/theme/app_theme.dart';

class NewExpenseDialog extends ConsumerStatefulWidget {
  const NewExpenseDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const NewExpenseDialog(),
    );
  }

  @override
  ConsumerState<NewExpenseDialog> createState() => _NewExpenseDialogState();
}

class _NewExpenseDialogState extends ConsumerState<NewExpenseDialog> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.rent;
  PaymentMethod _selectedPayment = PaymentMethod.cash;

  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amountStr = _amountController.text.trim();
    final desc = _descController.text.trim();

    if (amountStr.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir le montant et la description')),
      );
      return;
    }

    final amount = int.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(expenseRepositoryProvider).insertExpense(
            category: _selectedCategory,
            amount: amount,
            description: desc,
            date: DateTime.now(),
            paymentMethod: _selectedPayment,
          );

      ref.invalidate(expensesDataProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dépense enregistrée avec succès'),
            backgroundColor: AppColors.brandEmerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: context.colors.error,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.money_off_csred_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('Nouvelle Dépense',
                      style: AppTypography.labelMd.copyWith(color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Formulaire
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Catégorie *', style: AppTypography.labelSm),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    items: ExpenseCategory.values.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.label),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Montant (GNF) *', style: AppTypography.labelSm),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Ex: 150000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Description *', style: AppTypography.labelSm),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      hintText: 'Motif de la dépense',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Mode de paiement *', style: AppTypography.labelSm),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PaymentMethod>(
                    initialValue: _selectedPayment,
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    items: PaymentMethod.values.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.name.toUpperCase()),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPayment = val);
                    },
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Annuler', style: TextStyle(color: context.colors.onSurfaceVariant)),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: _isSaving ? null : _save,
                        style: FilledButton.styleFrom(backgroundColor: context.colors.error),
                        child: _isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Enregistrer'),
                      ),
                    ],
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
