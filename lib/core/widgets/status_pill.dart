import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Pastille de statut arrondie (ex. « Payé », « Crédit »).
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  /// Vente réglée.
  const StatusPill.paid({super.key})
      : label = 'Payé',
        background = AppColors.secondaryContainer,
        foreground = AppColors.onSecondaryContainer;

  /// Vente (partiellement) à crédit.
  const StatusPill.credit({super.key})
      : label = 'Crédit',
        background = AppColors.errorContainer,
        foreground = AppColors.onErrorContainer;

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
