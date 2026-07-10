import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Thème de l'application, assemblé à partir des tokens de la charte
/// ([AppColors], [AppTypography], [AppSpacing]). Interface épurée, lisible sur
/// matériel modeste.
class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onPrimary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.tertiaryFixed,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
    );
    return _base(scheme);
  }

  /// Thème sombre : palette gris profond/SaaS moderne.
  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: Color(0xFF334155), // gris ardoise
      onSecondaryContainer: Color(0xFFF8FAFC),
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onPrimary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.tertiaryFixed,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFFEF2F2),
      surface: Color(0xFF0F172A), // Tailwind Slate 900
      onSurface: Color(0xFFF8FAFC),
      onSurfaceVariant: Color(0xFF94A3B8), // Slate 400
      surfaceContainerLowest: Color(0xFF1E293B), // Slate 800 (pour les cartes)
      surfaceContainerLow: Color(0xFF334155), // Slate 700
      surfaceContainer: Color(0xFF475569), // Slate 600
      surfaceContainerHigh: Color(0xFF64748B), // Slate 500
      surfaceContainerHighest: Color(0xFF94A3B8),
      outline: Color(0xFF475569),
      outlineVariant: Color(0xFF334155),
      inverseSurface: Color(0xFFF8FAFC),
      onInverseSurface: Color(0xFF0F172A),
      inversePrimary: AppColors.inversePrimary,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    final textTheme = const TextTheme(
      displayLarge: AppTypography.displayLg,
      headlineLarge: AppTypography.headlineLg,
      headlineMedium: AppTypography.headlineMd,
      titleLarge: AppTypography.headlineMd,
      titleMedium: AppTypography.labelMd,
      bodyLarge: AppTypography.bodyLg,
      bodyMedium: AppTypography.bodyMd,
      bodySmall: AppTypography.bodySm,
      labelLarge: AppTypography.labelMd,
      labelMedium: AppTypography.labelMd,
      labelSmall: AppTypography.labelSm,
    ).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      dividerTheme: DividerThemeData(color: scheme.surfaceContainer, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: AppTypography.labelMd,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
      ),
    );
  }
}
