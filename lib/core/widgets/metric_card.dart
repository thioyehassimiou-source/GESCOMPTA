import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';

/// Carte indicateur du tableau de bord : label + icône colorée, grande valeur,
/// et une ligne de tendance (texte coloré + précision discrète).
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.secondaryContainer,
    this.valueColor = AppColors.onSurface,
    this.trendText,
    this.trendColor = AppColors.primary,
    this.trendHint,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color valueColor;

  /// Ex. « +14 % » ou « 3 en attente ».
  final String? trendText;
  final Color trendColor;

  /// Ex. « vs hier ».
  final String? trendHint;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hoverBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: AppTypography.labelSm
                      .copyWith(color: AppColors.onSurfaceVariant)),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value,
              style: AppTypography.headlineMd.copyWith(color: valueColor)),
          if (trendText != null) ...[
            const SizedBox(height: AppSpacing.base),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(trendText!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: trendColor)),
                if (trendHint != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(trendHint!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant)),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
