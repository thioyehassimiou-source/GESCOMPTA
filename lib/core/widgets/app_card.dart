import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Carte de base de la charte : fond clair, bord fin, coins arrondis (12) et
/// ombre douce. Brique commune à tous les écrans.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.onTap,
    this.hoverBorder = false,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  /// Bord qui passe au primaire au survol (cartes interactives).
  final bool hoverBorder;

  /// Rogne le contenu au rayon de la carte (utile pour les tableaux).
  final bool clip;

  static const _shadow = [
    BoxShadow(color: Color(0x1A101828), offset: Offset(0, 1), blurRadius: 3),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(AppRadius.xl);
    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surfaceContainerLowest,
        borderRadius: radius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: _shadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: onTap == null
            ? (clip ? ClipRRect(borderRadius: radius, child: content) : content)
            : InkWell(
                onTap: onTap,
                borderRadius: radius,
                child:
                    clip ? ClipRRect(borderRadius: radius, child: content) : content,
              ),
      ),
    );
  }
}
