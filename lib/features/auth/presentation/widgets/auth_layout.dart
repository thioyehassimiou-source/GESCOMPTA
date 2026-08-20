import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/animated_backdrop.dart';

import 'package:nmashop/core/theme/app_theme.dart';

/// Longueur minimale d'un mot de passe accepté.
const kMinPasswordLength = 6;

/// Mise en page commune aux écrans de connexion et d'inscription :
/// panneau de marque animé à gauche, formulaire lisible à droite.
///
/// Sur écran étroit, seul le formulaire reste, surmonté d'une entête réduite.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pitch,
    required this.child,
  });

  /// Titre du formulaire (« Content de vous revoir »).
  final String title;

  /// Ligne d'explication sous le titre.
  final String subtitle;

  /// Accroche affichée sur le panneau de marque.
  final String pitch;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 800;

    return Scaffold(
      backgroundColor: AppColors.brandNavy,
      body: isWide
          ? Row(
              children: [
                Expanded(flex: 5, child: _buildBrandPanel()),
                Expanded(flex: 5, child: _buildFormPanel()),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 200, child: _buildBrandPanel(compact: true)),
                  _buildFormPanel(),
                ],
              ),
            ),
    );
  }

  Widget _buildBrandPanel({bool compact = false}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const AnimatedBackdrop(scrimOpacity: 0.78),
        Padding(
          padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BrandLogo(height: compact ? 32 : 44),
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.xl),
              Text(
                pitch,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 20 : 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormPanel() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandNavyLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Libellé de champ, aligné sur celui de l'écran de configuration.
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Décoration commune des champs de saisie des écrans d'authentification.
InputDecoration authInputDecoration(
  String hint,
  IconData icon, {
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
    prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: context.colors.primary, width: 2),
    ),
  );
}

/// Bandeau d'erreur affiché au-dessus du bouton de validation.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: context.colors.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
