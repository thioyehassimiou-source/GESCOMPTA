import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

enum AppMetricVariant { standard, error, primary }

class AppMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final IconData icon;
  final AppMetricVariant variant;
  final String? trendText;
  final Widget? actionWidget;
  final String? description;

  /// Hauteur fixe de la carte. Indispensable : le contenu s'appuie sur des
  /// widgets à flex (`Spacer`, `Flexible`) qui exigent une hauteur bornée — sans
  /// elle, la carte plantée sous un parent à hauteur infinie (ex. une `Row` de
  /// cartes dans un `SingleChildScrollView`).
  final double height;

  const AppMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.suffix = '',
    this.variant = AppMetricVariant.standard,
    this.trendText,
    this.actionWidget,
    this.description,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (variant == AppMetricVariant.primary) {
      return Container(
        height: height,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A101828),
              offset: Offset(0, 1),
              blurRadius: 3,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primaryFixed, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (description != null) ...[
              const Spacer(),
              Text(
                description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
            if (actionWidget != null) ...[
              const Spacer(),
              actionWidget!,
            ],
          ],
        ),
      );
    }

    final isError = variant == AppMetricVariant.error;
    final iconColor = isError ? theme.colorScheme.error : theme.colorScheme.primary;
    final valueColor = isError ? theme.colorScheme.error : theme.colorScheme.primary;

    return AppCard(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  text: value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    if (suffix.isNotEmpty)
                      TextSpan(
                        text: ' $suffix',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (trendText != null || actionWidget != null) ...[
            const Spacer(),
            if (trendText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        trendText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (actionWidget != null) actionWidget!,
          ],
        ],
      ),
    );
  }
}
