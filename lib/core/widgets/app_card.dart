import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Carte de base N'MaShop — fond blanc, ombre douce, coins arrondis à 16px.
/// Aucune bordure visible. Design fidèle au dashboard de référence.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.accentColor,
    this.onTap,
    this.hoverBorder = false,
    this.clip = false,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? accentColor;
  final VoidCallback? onTap;
  final double? height;
  final bool hoverBorder;
  final bool clip;

  // Ombre légère façon SaaS : douce, pas agressive
  static const _shadow = [
    BoxShadow(
      color: Color(0x0D000000), // 5% noir
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% noir
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? context.colors.surfaceContainerLowest;
    final radius = BorderRadius.circular(16);
    final content = Padding(padding: padding, child: child);

    Widget innerContent = content;
    if (accentColor != null) {
      innerContent = ClipRRect(
        borderRadius: radius,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accentColor),
              Expanded(child: content),
            ],
          ),
        ),
      );
    }

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        // Pas de bordure — design épuré
        boxShadow: _shadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: onTap == null
            ? (clip && accentColor == null
                ? ClipRRect(borderRadius: radius, child: innerContent)
                : innerContent)
            : InkWell(
                onTap: onTap,
                borderRadius: radius,
                hoverColor: const Color(0x05000000),
                splashColor: const Color(0x08000000),
                child: clip && accentColor == null
                    ? ClipRRect(borderRadius: radius, child: innerContent)
                    : innerContent,
              ),
      ),
    );

    return height == null ? card : SizedBox(height: height, child: card);
  }
}
