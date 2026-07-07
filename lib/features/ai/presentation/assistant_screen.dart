import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _controller.clear();
    });

    // Mock AI response delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          String response = "Je traite votre demande. D'après vos données, ";
          if (text.toLowerCase().contains('vendu') || text.toLowerCase().contains('semaine')) {
            response += "vous avez généré 12 450 000 GNF cette semaine sur 42 transactions. Votre meilleure journée était mardi.";
          } else if (text.toLowerCase().contains('doit') || text.toLowerCase().contains('argent')) {
            response += "le client Alpha Bah a le solde impayé le plus élevé : 3 200 000 GNF.";
          } else {
            response += "je peux vous aider avec cela. Je consulte vos registres de stock et de ventes actuels.";
          }
          _messages.add({'isUser': false, 'text': response});
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: _messages.isEmpty
                ? _buildWelcomeState()
                : _buildChatHistory(),
          ),
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: _buildInputBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: const Center(
                child: Icon(Icons.smart_toy, size: 40, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Bonjour, Diallo.', style: AppTypography.displayLg.copyWith(fontSize: 32)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Demandez-moi n\'importe quoi sur vos performances, votre stock ou vos clients.',
              style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl * 2),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 5,
              children: [
                _buildSuggestionCard('Combien ai-je vendu cette semaine ?', Icons.trending_up, AppColors.primary),
                _buildSuggestionCard('Qui me doit le plus d\'argent ?', Icons.account_balance_wallet, AppColors.error),
                _buildSuggestionCard('Vérifier le stock du ciment "Baguira"', Icons.inventory_2, AppColors.secondary),
                _buildSuggestionCard('Générer le rapport fiscal mensuel', Icons.description, AppColors.tertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(String text, IconData icon, Color color) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _sendMessage(text),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  text,
                  style: AppTypography.labelMd,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatHistory() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.separated(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.xl,
            bottom: 120, // Espace pour l'input bar
          ),
          itemCount: _messages.length + 1,
          separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.xl),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildMessage(
                isUser: false,
                text: "Bon retour. J'ai analysé vos ventes du jour. Votre revenu total s'élève à 2 450 000 GNF, soit 15% de plus qu'hier à la même heure.",
              );
            }
            final msg = _messages[index - 1];
            return _buildMessage(isUser: msg['isUser'], text: msg['text']);
          },
        ),
      ),
    );
  }

  Widget _buildMessage({required bool isUser, required String text}) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Center(
              child: Icon(Icons.smart_toy, color: AppColors.primary, size: 18),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.primary : AppColors.surfaceContainerLow,
                  border: isUser ? null : Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(16).copyWith(
                    topLeft: isUser ? const Radius.circular(16) : Radius.zero,
                    topRight: isUser ? Radius.zero : const Radius.circular(16),
                  ),
                ),
                child: Text(
                  text,
                  style: AppTypography.bodyMd.copyWith(
                    color: isUser ? AppColors.onPrimary : AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'À l\'instant',
                style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Center(
              child: Icon(Icons.person, color: AppColors.onSurfaceVariant, size: 18),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                color: AppColors.onSurfaceVariant,
                onPressed: () {},
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'Posez votre question...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  color: Colors.white,
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'L\'IA GESCOMPTA peut faire des erreurs. Vérifiez les données financières importantes.',
          style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
