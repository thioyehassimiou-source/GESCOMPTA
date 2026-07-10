import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gescompta/core/widgets/app_metric_card.dart';

/// Régression : une carte d'indicateur doit se rendre même sous un parent à
/// hauteur non bornée (Row de cartes Expanded dans un SingleChildScrollView),
/// grâce à sa hauteur fixe. Sans elle, les Spacer/Flexible internes lançaient
/// « RenderFlex children have non-zero flex but incoming height constraints
/// are unbounded ».
void main() {
  testWidgets('AppMetricCard se rend sous hauteur non bornée sans erreur layout',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Row(
              children: const [
                Expanded(
                  child: AppMetricCard(
                    title: 'Valeur du Stock',
                    value: '1 250 000',
                    suffix: 'GNF',
                    icon: Icons.inventory_2,
                    trendText: '+4.2% ce mois',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AppMetricCard(
                    title: 'Alertes',
                    value: '3',
                    suffix: 'Produits',
                    icon: Icons.notification_important,
                    variant: AppMetricVariant.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Valeur du Stock'), findsOneWidget);
    expect(find.byType(AppMetricCard), findsNWidgets(2));
  });
}
