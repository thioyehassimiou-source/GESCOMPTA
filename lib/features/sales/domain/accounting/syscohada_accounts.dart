import '../../../../core/domain/payment_method.dart';

/// Comptes SYSCOHADA mobilisés par le moteur. Centralisés ici pour que les
/// règles comptables restent au même endroit (et évoluent sans toucher au
/// reste du moteur). Le commerçant ne voit jamais ces codes.
abstract final class SyscohadaAccounts {
  /// 571 — Caisse (espèces).
  static const cash = '571';

  /// 551 — Mobile money.
  static const mobileMoney = '551';

  /// 521 — Banques locales.
  static const bank = '521';

  /// 411 — Clients (créances).
  static const clients = '411';

  /// 701 — Ventes de marchandises.
  static const merchandiseSales = '701';

  /// 6031 — Variation des stocks de marchandises (sortie au coût).
  static const stockVariation = '6031';

  /// 311 — Marchandises (stock).
  static const merchandiseStock = '311';

  /// Compte de trésorerie correspondant à un règlement immédiat.
  static String forTender(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => cash,
        PaymentMethod.mobileMoney => mobileMoney,
        PaymentMethod.bank => bank,
        PaymentMethod.credit => throw ArgumentError(
            'Le crédit n\'est pas un compte de trésorerie'),
      };
}
