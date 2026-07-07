import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum AppChipStatus { success, warning, error, neutral }

/// Badge dynamique pour le statut (ex: "In Stock", "Critical Low") avec un point de couleur.
class AppChip extends StatelessWidget {
  final String label;
  final AppChipStatus status;

  const AppChip({
    super.key,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    Color dotColor;

    switch (status) {
      case AppChipStatus.success:
        backgroundColor = theme.colorScheme.primaryContainer.withOpacity(0.2);
        textColor = theme.colorScheme.primary;
        dotColor = theme.colorScheme.primary;
        break;
      case AppChipStatus.warning:
        backgroundColor = AppColors.warningContainer.withOpacity(0.6);
        textColor = AppColors.onWarningContainer;
        dotColor = AppColors.warning;
        break;
      case AppChipStatus.error:
        backgroundColor = theme.colorScheme.errorContainer.withOpacity(0.4);
        textColor = theme.colorScheme.onErrorContainer;
        dotColor = theme.colorScheme.error;
        break;
      case AppChipStatus.neutral:
        backgroundColor = theme.colorScheme.surfaceVariant.withOpacity(0.4);
        textColor = theme.colorScheme.onSurfaceVariant;
        dotColor = theme.colorScheme.outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 2.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: theme.textTheme.labelSmall?.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge simple avec fond (ex: pour afficher les quantités en stock "8 units").
class AppBadge extends StatelessWidget {
  final String text;
  final AppChipStatus status;

  const AppBadge({
    super.key,
    required this.text,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case AppChipStatus.success:
        backgroundColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.onSecondaryContainer;
        break;
      case AppChipStatus.warning:
        backgroundColor = AppColors.warningContainer;
        textColor = AppColors.onWarningContainer;
        break;
      case AppChipStatus.error:
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        break;
      case AppChipStatus.neutral:
        backgroundColor = theme.colorScheme.surfaceVariant;
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 2.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ).copyWith(color: textColor),
      ),
    );
  }
}
