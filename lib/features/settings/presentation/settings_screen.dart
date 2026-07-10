import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 8, child: _buildBusinessProfile()),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 4, child: _buildRightSidebar()),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildUserManagement(),
                const SizedBox(height: AppSpacing.xl),
                _buildAccountantSpace(),
                const SizedBox(height: AppSpacing.xl),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Réglages', style: AppTypography.headlineMd.copyWith(color: AppColors.primary)),
            Text('Configurez votre écosystème d\'entreprise', style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  Widget _buildBusinessProfile() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profil de l\'entreprise', style: AppTypography.labelMd.copyWith(color: AppColors.primary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Gérez vos informations publiques et de facturation.', style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
              AppButton(label: 'Enregistrer', onPressed: () {}),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _buildTextField('Nom de l\'entreprise', 'GESCOMPTA Merchant')),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: _buildTextField('NIF', 'GN-884-293-X')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _buildTextField('Adresse E-mail', 'contact@gescompta.gn')),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Devise', style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.base),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.outlineVariant),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: 'GNF (Franc Guinéen)',
                          items: const [
                            DropdownMenuItem(value: 'GNF (Franc Guinéen)', child: Text('GNF (Franc Guinéen)')),
                            DropdownMenuItem(value: 'USD (US Dollar)', child: Text('USD (US Dollar)')),
                            DropdownMenuItem(value: 'EUR (Euro)', child: Text('EUR (Euro)')),
                          ],
                          onChanged: (v) {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextField('Adresse de l\'entreprise', 'Immeuble Kaloum, 4ème étage, Conakry, Guinée', maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.base),
        TextFormField(
          initialValue: value,
          maxLines: maxLines,
          decoration: const InputDecoration(
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildRightSidebar() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.3),
            border: Border.all(color: AppColors.secondaryContainer),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.workspace_premium, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Forfait Merchant Pro', style: AppTypography.labelMd.copyWith(color: AppColors.onSecondaryContainer)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Prochaine Facturation', style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                  Text('Oct 12, 2023', style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Statut', style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('ACTIF', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: 0.75,
                backgroundColor: AppColors.surfaceContainer,
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
                minHeight: 4,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('75% de stockage mensuel utilisé', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('Gérer l\'abonnement'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sécurité Rapide', style: AppTypography.labelMd.copyWith(color: AppColors.primary)),
              const SizedBox(height: AppSpacing.md),
              _buildSecurityItem(Icons.lock_reset, 'Changer le mot de passe', trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant)),
              const SizedBox(height: AppSpacing.xs),
              _buildSecurityItem(Icons.verified_user, 'Double Authentification (2FA)',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('DÉSACTIVÉ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onErrorContainer)),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityItem(IconData icon, String title, {required Widget trailing}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppRadius.lg),
      hoverColor: AppColors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTypography.bodySm),
              ],
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildUserManagement() {
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gestion des Utilisateurs', style: AppTypography.labelMd.copyWith(color: AppColors.primary)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Invitez votre équipe et contrôlez les accès.', style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
                AppButton.secondary(icon: Icons.person_add, label: 'Ajouter un Utilisateur', onPressed: () {}),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          DataTable(
            headingRowColor: WidgetStatePropertyAll(AppColors.secondaryContainer.withValues(alpha: 0.4)),
            dataRowMaxHeight: 64,
            columns: const [
              DataColumn(label: Text('NOM & E-MAIL')),
              DataColumn(label: Text('RÔLE')),
              DataColumn(label: Text('DERNIÈRE ACTIVITÉ')),
              DataColumn(label: Text('ACTION')),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Row(
                  children: [
                    CircleAvatar(backgroundColor: AppColors.primaryFixed, foregroundColor: AppColors.primary, child: const Text('MB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mamadou Barry', style: AppTypography.labelMd),
                        Text('m.barry@gescompta.gn', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                )),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(16)),
                    child: const Text('PROPRIÉTAIRE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onPrimaryContainer)),
                  ),
                ),
                DataCell(Text('À l\'instant', style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant))),
                DataCell(IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})),
              ]),
              DataRow(cells: [
                DataCell(Row(
                  children: [
                    CircleAvatar(backgroundColor: AppColors.secondaryContainer, foregroundColor: AppColors.onSecondaryContainer, child: const Text('SC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Salimatou Camara', style: AppTypography.labelMd),
                        Text('s.camara@gescompta.gn', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                )),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                    child: Text('VENTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                  ),
                ),
                DataCell(Text('Il y a 2 heures', style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant))),
                DataCell(IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountantSpace() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
        border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                ),
                child: const Icon(Icons.account_balance, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Espace Comptable', style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                  Text('Accès direct au grand livre pour les rapports fiscaux autorisés.', style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text('A', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.md),
              TextButton(onPressed: () {}, child: Text('Lancer le Portail d\'Audit', style: AppTypography.labelMd.copyWith(color: AppColors.primary))),
              const SizedBox(width: AppSpacing.xs),
              IconButton(icon: const Icon(Icons.settings_applications), color: AppColors.outline, onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(color: AppColors.outlineVariant),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('© 2023 GESCOMPTA S.A. | Built for the future of Guinean Commerce.', style: TextStyle(fontSize: 10, color: AppColors.outline)),
            Row(
              children: [
                TextButton(onPressed: () {}, child: const Text('Terms of Service', style: TextStyle(fontSize: 10, color: AppColors.outline))),
                TextButton(onPressed: () {}, child: const Text('Privacy Policy', style: TextStyle(fontSize: 10, color: AppColors.outline))),
                TextButton(onPressed: () {}, child: const Text('API Documentation', style: TextStyle(fontSize: 10, color: AppColors.outline))),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
