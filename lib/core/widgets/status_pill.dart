import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';

/// Pastille de statut arrondie (ex. « Payé », « Crédit »).
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.background,
    this.foreground,
  });

  /// Vente réglée : suit le template de la boutique.
  StatusPill.paid({super.key})
    : label = 'Payé',
      background = null,
      foreground = null;

  /// Vente (partiellement) à crédit. Le rouge d'alerte ne dépend pas du
  /// template : une dette doit se repérer à l'identique partout.
  StatusPill.credit({super.key})
    : label = 'Crédit',
      background = context.colors.errorContainer,
      foreground = context.colors.onErrorContainer;

  final String label;

  /// Couleurs facultatives : par défaut, celles du template.
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background ?? context.colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground ?? context.colors.onSecondaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
