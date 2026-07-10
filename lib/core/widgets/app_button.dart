import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  }) : variant = AppButtonVariant.secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final bool isPrimary = variant == AppButtonVariant.primary;
    
    final backgroundColor = isPrimary ? theme.colorScheme.primary : theme.colorScheme.secondaryContainer;
    final foregroundColor = isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: isPrimary ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              )
            ] : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: foregroundColor),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isSecondary;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(isSecondary ? AppRadius.lg : AppRadius.full),
          hoverColor: isSecondary ? theme.colorScheme.secondaryContainer : theme.colorScheme.surfaceContainer,
          child: Padding(
            padding: EdgeInsets.all(isSecondary ? 6.0 : AppSpacing.base),
            child: Icon(
              icon,
              size: 20,
              color: isSecondary ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
