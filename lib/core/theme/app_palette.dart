import 'package:flutter/material.dart';

/// Template visuel de la boutique.
///
/// Chaque métier a ses codes : le bleu clinique d'une pharmacie ne convient pas
/// à une boutique de mode. Le commerçant choisit son template à la
/// configuration, et il colore toute l'application.
///
/// [id] est persisté dans les préférences : ne jamais le renommer.
enum AppPalette {
  emeraude(
    id: 'emeraude',
    label: 'Émeraude',
    trade: 'Commerce général',
    seed: Color(0xFF006054),
    accent: Color(0xFF10B981),
  ),
  clinique(
    id: 'clinique',
    label: 'Clinique',
    trade: 'Pharmacie, santé',
    seed: Color(0xFF0369A1),
    accent: Color(0xFF06B6D4),
  ),
  prune(
    id: 'prune',
    label: 'Prune',
    trade: 'Mode, cosmétique',
    seed: Color(0xFF7C3AED),
    accent: Color(0xFFC026D3),
  ),
  safran(
    id: 'safran',
    label: 'Safran',
    trade: 'Alimentation, restauration',
    seed: Color(0xFFEA580C),
    accent: Color(0xFFF59E0B),
  ),
  indigo(
    id: 'indigo',
    label: 'Indigo',
    trade: 'Électronique, téléphonie',
    seed: Color(0xFF1D4ED8),
    accent: Color(0xFF3B82F6),
  ),
  ardoise(
    id: 'ardoise',
    label: 'Ardoise',
    trade: 'Quincaillerie, matériaux',
    seed: Color(0xFF334155),
    accent: Color(0xFFB45309),
  );

  const AppPalette({
    required this.id,
    required this.label,
    required this.trade,
    required this.seed,
    required this.accent,
  });

  /// Identifiant stable, stocké dans les préférences.
  final String id;

  /// Nom affiché au commerçant.
  final String label;

  /// Métiers auxquels ce template s'adresse.
  final String trade;

  /// Couleur mère dont dérive tout le nuancier.
  final Color seed;

  /// Couleur d'accent, pour les mises en avant et les graphiques.
  final Color accent;

  /// Template appliqué par défaut, avant tout choix du commerçant.
  static const fallback = AppPalette.emeraude;

  /// Retrouve un template par son [id]. Retombe sur [fallback] si l'id est
  /// inconnu (template supprimé lors d'une mise à jour, préférence corrompue).
  static AppPalette fromId(String? id) {
    return AppPalette.values.firstWhere(
      (p) => p.id == id,
      orElse: () => fallback,
    );
  }

  /// Template suggéré pour un domaine d'activité choisi à la configuration.
  ///
  /// Simple pré-sélection : le commerçant reste libre de changer.
  static AppPalette suggestedFor(String? businessDomain) {
    if (businessDomain == null) return fallback;
    final domain = businessDomain.toLowerCase();

    if (domain.contains('pharmacie') || domain.contains('santé')) {
      return AppPalette.clinique;
    }
    if (domain.contains('mode') ||
        domain.contains('cosmétique') ||
        domain.contains('beauté')) {
      return AppPalette.prune;
    }
    if (domain.contains('alimentation') ||
        domain.contains('restaurant') ||
        domain.contains('boulangerie')) {
      return AppPalette.safran;
    }
    if (domain.contains('électronique') ||
        domain.contains('informatique') ||
        domain.contains('téléphonie')) {
      return AppPalette.indigo;
    }
    if (domain.contains('quincaillerie') ||
        domain.contains('matéri') ||
        domain.contains('équipement')) {
      return AppPalette.ardoise;
    }
    return fallback;
  }
}
