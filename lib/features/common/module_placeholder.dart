import 'package:flutter/material.dart';

/// Écran d'attente pour les modules non encore implémentés.
/// Affiche l'intention fonctionnelle pour cadrer le développement à venir.
class ModulePlaceholder extends StatelessWidget {
  const ModulePlaceholder({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.bullets = const [],
  });

  final String title;
  final IconData icon;
  final String description;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(description, style: theme.textTheme.bodyLarge),
              if (bullets.isNotEmpty) ...[
                const SizedBox(height: 20),
                for (final b in bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(b)),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              Chip(
                avatar: const Icon(Icons.construction, size: 18),
                label: const Text('Module à venir'),
                backgroundColor:
                    theme.colorScheme.secondaryContainer.withValues(alpha: .5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
