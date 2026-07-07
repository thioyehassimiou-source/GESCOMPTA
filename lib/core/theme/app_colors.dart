import 'package:flutter/material.dart';

/// Palette de la charte GESCOMPTA (Material 3, teal « commerce »).
///
/// Source de vérité unique des couleurs : les valeurs proviennent directement
/// des maquettes. Aucune couleur ne doit être écrite en dur ailleurs.
abstract final class AppColors {
  // ── Primaire ──
  static const primary = Color(0xFF006054);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF0F7B6C);
  static const onPrimaryContainer = Color(0xFFB5FFEF);
  static const primaryFixed = Color(0xFF99F3E0);

  // ── Secondaire ──
  static const secondary = Color(0xFF4B635C);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFCDE8DF);
  static const onSecondaryContainer = Color(0xFF516962);
  static const onSecondaryFixedVariant = Color(0xFF344B45);

  // ── Tertiaire ──
  static const tertiary = Color(0xFF4D5567);
  static const tertiaryContainer = Color(0xFF656D80);
  static const tertiaryFixed = Color(0xFFDBE2F9);
  static const onTertiaryFixedVariant = Color(0xFF3F4759);

  // ── Avertissement (ambre) — statut « à recommander » ──
  static const warning = Color(0xFFF97316);
  static const warningContainer = Color(0xFFFFF4E5);
  static const onWarningContainer = Color(0xFFB45309);

  // ── Erreur ──
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // ── Surfaces ──
  static const background = Color(0xFFF8FAF9);
  static const surface = Color(0xFFF8FAF9);
  static const surfaceBright = Color(0xFFF8FAF9);
  static const surfaceDim = Color(0xFFD8DADA);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F4F3);
  static const surfaceContainer = Color(0xFFECEEED);
  static const surfaceContainerHigh = Color(0xFFE6E9E8);
  static const surfaceContainerHighest = Color(0xFFE1E3E2);
  static const surfaceVariant = Color(0xFFE1E3E2);

  // ── Contenus ──
  static const onSurface = Color(0xFF191C1C);
  static const onSurfaceVariant = Color(0xFF3E4946);
  static const onBackground = Color(0xFF191C1C);
  static const outline = Color(0xFF6E7976);
  static const outlineVariant = Color(0xFFBDC9C5);

  // ── Inverses ──
  static const inverseSurface = Color(0xFF2E3131);
  static const inverseOnSurface = Color(0xFFEFF1F0);
  static const inversePrimary = Color(0xFF7CD7C5);
}
