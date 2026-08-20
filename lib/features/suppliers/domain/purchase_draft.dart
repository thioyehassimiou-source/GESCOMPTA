import '../../../../core/domain/payment_method.dart';

class PurchaseDraft {
  const PurchaseDraft({
    required this.supplierName,
    required this.lines,
    required this.amountPaid,
    required this.paymentMethod,
    this.date,
  });

  final String supplierName;
  final List<PurchaseDraftLine> lines;
  final int amountPaid;
  final PaymentMethod paymentMethod;
  final DateTime? date;

  int get totalAmount => lines.fold(0, (sum, line) => sum + line.lineTotal);
}

class PurchaseDraftLine {
  const PurchaseDraftLine({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final int quantity;
  final int unitPrice;

  int get lineTotal => unitPrice * quantity;
}
