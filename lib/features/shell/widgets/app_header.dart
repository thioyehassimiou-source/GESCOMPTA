import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_search_bar.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    
    String title = 'GESCOMPTA';
    String subtitle = 'Gestion des Stocks';
    String placeholder = 'Rechercher...';
    
    if (location.startsWith('/fournisseurs')) {
      title = 'Fournisseurs';
      subtitle = 'Achats & Dettes';
      placeholder = 'Rechercher un fournisseur ou ID d\'achat...';
    } else if (location.startsWith('/produits')) {
      title = 'GESCOMPTA';
      subtitle = 'Gestion des Stocks';
      placeholder = 'Rechercher un produit, réf. ou catégorie...';
    }

    return Container(
      height: AppSpacing.topBarHeight,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14101828), offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            Text(title,
                style: AppTypography.headlineMd.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
            const SizedBox(width: AppSpacing.md),
            Container(
              height: 24,
              width: 1,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(subtitle.toUpperCase(),
                style: AppTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant, letterSpacing: 1.5)),
            const Spacer(),
            SizedBox(
              width: 400,
              child: AppSearchBar(hintText: placeholder),
            ),
            const Spacer(),
            _iconButton(context, Icons.notifications_outlined, badge: true),
            const SizedBox(width: AppSpacing.xs),
            _iconButton(context, Icons.help_outline),
            const SizedBox(width: AppSpacing.sm),
            const _ProfileChip(),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(BuildContext context, IconData icon, {bool badge = false}) {
    return IconButton(
      onPressed: () {},
      icon: Stack(
        children: [
          Icon(icon, color: AppColors.onSurfaceVariant),
          if (badge)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
      style: IconButton.styleFrom(
        hoverColor: AppColors.surfaceContainer,
        shape: const CircleBorder(),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Alpha Diallo',
                style: AppTypography.labelMd
                    .copyWith(fontWeight: FontWeight.w700)),
            const Text('Guinée Commerce',
                style: TextStyle(
                    fontSize: 10, color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondaryContainer,
            border: Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: const Center(
            child: Icon(Icons.person, color: AppColors.onSecondaryContainer),
          ),
        ),
      ],
    );
  }
}
