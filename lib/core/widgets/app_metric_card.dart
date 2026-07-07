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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (variant == AppMetricVariant.primary) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: theme.colorScheme.primaryFixed, size: 24),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
            if (actionWidget != null) ...[
              const SizedBox(height: AppSpacing.md),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              RichText(
                text: TextSpan(
                  text: value,
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: valueColor,
                  ),
                  children: [
                    if (suffix.isNotEmpty)
                      TextSpan(
                        text: ' $suffix',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (trendText != null || actionWidget != null) ...[
            const SizedBox(height: AppSpacing.md),
            if (trendText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      trendText!,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
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
