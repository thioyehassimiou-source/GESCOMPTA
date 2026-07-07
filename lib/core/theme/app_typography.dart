import 'package:flutter/material.dart';

/// Échelle typographique de la charte (police Inter).
/// Reproduit fidèlement les tailles/graisses/interlignages des maquettes.
abstract final class AppTypography {
  static const fontFamily = 'Inter';

  static const displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    height: 60 / 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.96, // -0.02em
  );

  static const headlineLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.64, // -0.02em
  );

  static const headlineMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
  );

  static const bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w400,
  );

  static const bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  static const labelMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
  );

  static const labelSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w500,
  );
}
