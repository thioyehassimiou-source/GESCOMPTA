import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_search_bar.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final theme = Theme.of(context);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

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
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
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
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5)),
            const SizedBox(width: AppSpacing.md),
            Container(height: 24, width: 1, color: theme.colorScheme.outlineVariant),
            const SizedBox(width: AppSpacing.md),
            Text(subtitle.toUpperCase(),
                style: AppTypography.labelSm.copyWith(
                    color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
            const Spacer(),
            SizedBox(
              width: 400,
              child: AppSearchBar(hintText: placeholder),
            ),
            const Spacer(),
            // ── Bouton toggle thème ──
            _ThemeToggle(isDark: isDark, ref: ref),
            const SizedBox(width: AppSpacing.xs),
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
    final theme = Theme.of(context);
    return IconButton(
      onPressed: () {},
      icon: Stack(
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          if (badge)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
      style: IconButton.styleFrom(
        hoverColor: theme.colorScheme.surfaceContainer,
        shape: const CircleBorder(),
      ),
    );
  }
}

/// Bouton de bascule thème dans l'en-tête.
class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isDark, required this.ref});

  final bool isDark;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: isDark ? 'Passer en mode clair' : 'Passer en mode sombre',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: InkWell(
          onTap: () => ref.read(themeProvider.notifier).toggle(),
          borderRadius: BorderRadius.circular(AppRadius.full),
          hoverColor: theme.colorScheme.surfaceContainer,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  RotationTransition(
                    turns: Tween(begin: 0.8, end: 1.0).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
                size: 20,
                color: isDark
                    ? const Color(0xFFFCD34D) // jaune soleil en mode sombre
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Alpha Diallo',
                style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface)),
            Text('Guinée Commerce',
                style: TextStyle(
                    fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.secondaryContainer,
            border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
          ),
          child: Center(
            child: Icon(Icons.person, color: theme.colorScheme.onSecondaryContainer),
          ),
        ),
      ],
    );
  }
}
